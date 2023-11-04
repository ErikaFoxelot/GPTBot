import Foundation

struct PerfResults: CustomStringConvertible {
  var duration: Double = 0
  var tokensSent: Int = 0
  var tokensReceived: Int = 0
  var completedSuccessfully: Bool = false

  var description: String {
    return
      """
      Completed Successfully: \(completedSuccessfully)
      Duration: \(Int(duration * 1000))ms
      Tokens Sent: \(tokensSent)
      Tokens Received: \(tokensReceived)
      """
  }
}
