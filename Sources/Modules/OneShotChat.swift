import Foundation
import GPTEncoder
import OpenAI

struct OneShotChat {
    var config: OneShotConfig
    let encoding = GPTEncoder()

    init(config: OneShotConfig) {
        self.config = config
    }

    func evaluate() async throws -> PerfResults {
        let client = buildAPIClient()
        let messages = buildMessages()
        let tokensSent = calculateTokensSent(messages)
        let query = buildQuery(messages, tokensSent)

        return config.inStreamingMode
            ? try await evaluateStreaming(client, query, tokensSent)
            : try await evaluateNonStreaming(client, query)
    }

    func evaluateStreaming(_ client: OpenAI, _ query: ChatQuery, _ tokensSent: Int) async throws -> PerfResults {
        var perfResults: PerfResults = PerfResults()
        perfResults.duration = try await Measure {
            var isFirstResponse = true
            for try await partialResult in client.chatsStream(query: query) {
                let content = partialResult.choices[0].delta.content ?? ""
                perfResults.tokensReceived += config.includeStatistics ? encoding.encode(text: content).count : 0
                try outputResponse(
                    content, first: isFirstResponse,
                    complete: partialResult.choices[0].finishReason != nil)
                isFirstResponse = isFirstResponse && content.isEmpty
            }
            perfResults.tokensSent = tokensSent
        }
        perfResults.completedSuccessfully = true
        return perfResults
    }

    func evaluateNonStreaming(_ client: OpenAI, _ query: ChatQuery) async throws -> PerfResults {
        var perfResults: PerfResults = PerfResults()
        perfResults.duration = try await Measure {
            let result = try await client.chats(query: query)
            let content = result.choices[0].message.content ?? ""
            perfResults.tokensSent = result.usage?.promptTokens ?? 0
            perfResults.tokensReceived = result.usage?.completionTokens ?? 0
            try outputResponse(content, first: true, complete: true)
        }
        perfResults.completedSuccessfully = true
        return perfResults
    }

    func buildAPIClient() -> OpenAI {
        return OpenAI(
            configuration: OpenAI.Configuration(
                token: config.apiKey,
                organizationIdentifier: config.apiOrg
            ))
    }

    func buildQuery(_ messages: [Chat], _ tokensSent: Int) -> ChatQuery {
        return ChatQuery(
            model: config.model,
            messages: messages,
            //functions: buildFunctions(),
            temperature: config.temperature,
            maxTokens: config.maxTokens - tokensSent
        )
    }

    func buildMessages() -> [Chat] {
        return [Chat(role: .system, content: config.systemPrompt)]
            + config.userPrompts.map { prompt in
                Chat(role: .user, content: prompt)
            }
    }

    func calculateTokensSent(_ messages: [Chat]) -> Int {
        var numTokens = 0
        for message in messages {
            numTokens += 4
            if let content = message.content {
                numTokens += encoding.encode(text: content).count
            }
            if let name = message.name, !name.isEmpty {
                numTokens -= 1
            }
        }
        numTokens += 2
        return numTokens
    }

    func outputResponse(_ response: String, first: Bool = false, complete: Bool) throws {
        if let outputFile = config.outputFile {
            guard !response.isEmpty else { return }

            let fileURL = URL(fileURLWithPath: outputFile)
            let fileManager = FileManager.default

            if !fileManager.fileExists(atPath: outputFile) {
                fileManager.createFile(atPath: outputFile, contents: nil)
            }

            if first && config.overwriteOutput {
                try fileManager.removeItem(at: fileURL)
                fileManager.createFile(atPath: outputFile, contents: nil)
            }

            try fileManager.safeAppendToFile(url: fileURL, contents: response, truncateFirst: first)
        } else {
            print(response, terminator: complete ? "\n" : "")
            fflush(__stdoutp)
        }
    }
}
