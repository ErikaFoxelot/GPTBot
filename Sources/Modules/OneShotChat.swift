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
    let query = buildQuery()

    return config.inStreamingMode
      ? try await evaluateStreaming(client, query)
      : try await evaluateNonStreaming(client, query)
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

  func evaluateStreaming(_ client: OpenAI, _ query: ChatQuery) async throws -> PerfResults {
    var perfResults: PerfResults = PerfResults()
    perfResults.duration = try await Measure {
      var isFirstResponse = true
      for try await partialResult in client.chatsStream(query: query) {
        let content = partialResult.choices[0].delta.content ?? ""
        perfResults.tokensReceived += encoding.encode(text: content).count
        try outputResponse(
          content, first: isFirstResponse, complete: partialResult.choices[0].finishReason != nil)
        isFirstResponse = isFirstResponse && content.isEmpty
      }
      perfResults.tokensSent = config.includeStatistics ? calculateTokensSent() : 0
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

  func buildQuery() -> ChatQuery {
    return ChatQuery(
      model: config.model,
      messages: buildMessages(),
      //functions: buildFunctions(),
      temperature: config.temperature,
      maxTokens: config.maxTokens - calculateTokensSent()
    )
  }

  func buildMessages() -> [Chat] {
    return [Chat(role: .system, content: config.systemPrompt)]
      + config.userPrompts.map { prompt in
        Chat(role: .user, content: prompt)
      }
  }

  func calculateTokensSent() -> Int {
    return encoding.encode(text: config.systemPrompt).count
      + config.userPrompts.reduce(0) { $0 + encoding.encode(text: $1).count }
  }

  func outputResponse(_ response: String, first: Bool = false, complete: Bool) throws {
    if let outputFile = config.outputFile {
      guard !response.isEmpty else { return }

      let fileURL = URL(fileURLWithPath: outputFile)
      let fileManager = FileManager.default

      if !fileManager.fileExists(atPath: outputFile) {
        fileManager.createFile(atPath: outputFile, contents: nil)
      }

      try fileManager.safeAppendToFile(url: fileURL, contents: response, truncateFirst: first)
    } else {
      print(response, terminator: complete ? "\n" : "")
      fflush(__stdoutp)
    }
  }
}
