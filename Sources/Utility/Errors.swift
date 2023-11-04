enum GPTBotError: Error {
  case fileError(String, Error? = nil)
  case apiError(String, Error? = nil)

  static func fileUnreadable(path: String, error: Error? = nil) -> GPTBotError {
    return .fileError("Unreadable file at path: \(path)", error)
  }

  static func apiReturnedError(message: String, error: Error? = nil) -> GPTBotError {
    return .apiError(message, error)
  }
}
