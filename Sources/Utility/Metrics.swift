import Foundation

// Synchronous, non-throwing function without a return value
func Measure(_ block: () -> Void) -> TimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    block()
    return CFAbsoluteTimeGetCurrent() - startTime
}

// Synchronous, non-throwing function with a return value
func Measure<T>(_ block: () -> T) -> (result: T, duration: TimeInterval) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = block()
    let duration = CFAbsoluteTimeGetCurrent() - startTime
    return (result, duration)
}

// Synchronous, throwing function without a return value
func Measure(_ block: () throws -> Void) rethrows -> TimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    try block()
    return CFAbsoluteTimeGetCurrent() - startTime
}

// Synchronous, throwing function with a return value
func Measure<T>(_ block: () throws -> T) rethrows -> (result: T, duration: TimeInterval) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try block()
    let duration = CFAbsoluteTimeGetCurrent() - startTime
    return (result, duration)
}

// Asynchronous, non-throwing function without a return value
func Measure(async block: () async -> Void) async -> TimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    await block()
    return CFAbsoluteTimeGetCurrent() - startTime
}

// Asynchronous, non-throwing function with a return value
func Measure<T>(async block: () async -> T) async -> (result: T, duration: TimeInterval) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = await block()
    let duration = CFAbsoluteTimeGetCurrent() - startTime
    return (result, duration)
}

// Asynchronous, throwing function without a return value
func Measure(async block: () async throws -> Void) async rethrows -> TimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    try await block()
    return CFAbsoluteTimeGetCurrent() - startTime
}

// Asynchronous, throwing function with a return value
func Measure<T>(async block: () async throws -> T) async rethrows -> (
    result: T, duration: TimeInterval
) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try await block()
    let duration = CFAbsoluteTimeGetCurrent() - startTime
    return (result, duration)
}
