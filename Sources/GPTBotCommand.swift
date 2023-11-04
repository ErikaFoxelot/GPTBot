import ArgumentParser
import Foundation

@main
struct GPTBotCommand: AsyncParsableCommand {
  static var configuration: CommandConfiguration = CommandConfiguration(
    commandName: "gptbot",
    abstract: "A command line tool for interacting with OpenAI's chat models."
  )

  @Flag(name: [.long], help: "Enable debug mode.")
  var debug: Bool = false

  @Flag(name: [.long], help: "Enable streaming mode - emit the response as it comes in.")
  var stream: Bool = false

  @Flag(name: [.customLong("stats")], help: "Include performance statistics in the response.")
  var includeStatistics: Bool = false

  @Option(
    name: [.long],
    help:
      "OpenAI API key. See https://platform.openai.com/account/api-keys. If not specified, the OPENAI_API_KEY environment variable will be used."
  )
  var apiKey: String = ""

  @Option(
    name: [.long],
    help:
      "OpenAI API organization. See https://platform.openai.com/account/org-settings. If not specified, the OPENAI_ORGANIZATION environment variable will be used."
  )
  var org: String = ""

  @Option(
    name: [.short, .long],
    help:
      """
      Path to file or files to include with the user prompt.
      If input files are used, a prompt does not need to be specified.
      If a file is binary, prefix its path with '!'.
      To read from standard input, use 'stdin' as the path.
      """
  )
  var inputFiles: [String] = []

  @Option(
    name: [.short, .long],
    help:
      "Path to a file to use as the system prompt. If not specified, a default system prompt will be used."
  )
  var systemPromptFile: String?

  @Option(
    name: [.short, .long],
    help:
      "Path to output the response to. This file will be overwritten if it already exists. If specified, the response will not be printed to the console."
  )
  var outputFile: String?

  @Option(
    name: [.long], help: "Temperature to use for the model. Value between 0 and 1."
  )
  var temperature: Double = Defaults.temperature

  @Option(
    name: [.long],
    help: "Max tokens to use for the model. Value between 1 and 4096."
  )
  var maxTokens: Int = Defaults.maxTokens

  @Option(
    name: [.long],
    help:
      "The model to use for the response. See https://platform.openai.com/docs/models/ for a list of available models."
  )
  var model: String = Defaults.model

  @Argument(help: "The prompt to use for the response. Can be left empty if input files are used.")
  var prompt: String?

  func isValidPath(_ path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
  }

  func fetchEnvironmentVariable(key: String) -> String? {
    return ProcessInfo.processInfo.environment[key]
  }

  func validate() throws {
    // Ensure the API key is set
    guard !(apiKey.isEmpty && fetchEnvironmentVariable(key: "OPENAI_API_KEY") == nil) else {
      throw ValidationError("OPENAI_API_KEY environment variable not set. Exiting...")
    }

    // Ensure either input files or a prompt is specified
    guard !(inputFiles.isEmpty && prompt == nil) else {
      throw ValidationError(
        "Either standard input (stdin) or an input file and/or a prompt must be specified")
    }

    // Ensure the input files exist
    for inputFile: String in inputFiles {
      let filePath: String = inputFile.hasPrefix("!") ? String(inputFile.dropFirst()) : inputFile
      if filePath != "stdin" {
        guard isValidPath(filePath) else {
          throw ValidationError("Input file \(filePath) does not exist")
        }
      }
    }

    // Ensure the system prompt file exists
    if let systemPromptFile: String {
      guard isValidPath(systemPromptFile) else {
        throw ValidationError("Prompt file \(systemPromptFile) does not exist")
      }
    }

    // Ensure maxTokens is within range
    guard maxTokens >= 1 && maxTokens <= 4096 else {
      throw ValidationError("Max tokens (\(maxTokens)) must be between 1 and 4096")
    }

    // Ensure temperature is within range
    guard temperature >= 0 && temperature <= 1 else {
      throw ValidationError("Temperature (\(temperature)) must be between 0 and 1")
    }
  }

  func buildConfiguration() throws -> OneShotConfig {
    // Resolve input files:
    var userPrompts: [String] = []
    if !inputFiles.isEmpty {
      for var file: String in inputFiles {
        var isBinary: Bool = false
        if file.hasPrefix("!") {
          isBinary = true
          file = String(file.dropFirst())
        }

        var fileData: Data

        if file == "stdin" {
          fileData = FileHandle.standardInput.readDataToEndOfFile()
        } else {
          do {
            fileData = try Data(contentsOf: URL(fileURLWithPath: file))
          } catch {
            throw GPTBotError.fileUnreadable(path: file, error: error)
          }
        }

        if isBinary {
          userPrompts.append(fileData.base64EncodedString())
        } else {
          if let fileContents: String = String(data: fileData, encoding: .utf8) {
            userPrompts.append(fileContents)
          } else {
            throw GPTBotError.fileUnreadable(path: file)
          }
        }
      }
    }

    if let prompt: String {
      userPrompts.append(prompt)
    }

    // Resolve system prompt file:
    var systemPrompt: String = Defaults.systemPrompt
    if let systemPromptFile: String {
      do {
        systemPrompt = try String(contentsOfFile: systemPromptFile)
      } catch {
        throw GPTBotError.fileUnreadable(path: systemPromptFile, error: error)
      }
    }

    return OneShotConfig(
      inDebugMode: debug,
      inStreamingMode: stream,
      includeStatistics: includeStatistics,
      systemPrompt: systemPrompt,
      userPrompts: userPrompts,
      outputFile: outputFile,
      temperature: temperature,
      maxTokens: maxTokens,
      model: model,
      apiKey: apiKey.isEmpty ? fetchEnvironmentVariable(key: "OPENAI_API_KEY")! : apiKey,
      apiOrg: org.isEmpty ? fetchEnvironmentVariable(key: "OPENAI_ORGANIZATION")! : org
    )
  }

  mutating func run() async throws {
    do {
      // Evaluate the prompt
      let perfResults = try await OneShotChat(
        config: buildConfiguration()
      ).evaluate()
      if includeStatistics {
        print(perfResults)
      }

    } catch {
      throw error
    }
  }
}
