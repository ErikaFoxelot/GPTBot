import Foundation

struct OneShotConfig {
  var inDebugMode: Bool
  var inStreamingMode: Bool
  var includeStatistics: Bool
  var systemPrompt: String
  var userPrompts: [String]
  var outputFile: String?
  var temperature: Double
  var maxTokens: Int
  var model: String
  var apiKey: String
  var apiOrg: String

  init(
    inDebugMode: Bool, inStreamingMode: Bool, includeStatistics: Bool, systemPrompt: String,
    userPrompts: [String],
    outputFile: String?, temperature: Double, maxTokens: Int, model: String,
    apiKey: String, apiOrg: String
  ) {
    self.inDebugMode = inDebugMode
    self.inStreamingMode = inStreamingMode
    self.includeStatistics = includeStatistics
    self.systemPrompt = systemPrompt
    self.userPrompts = userPrompts
    self.outputFile = outputFile
    self.temperature = temperature
    self.maxTokens = maxTokens
    self.model = model
    self.apiKey = apiKey
    self.apiOrg = apiOrg
  }
}
