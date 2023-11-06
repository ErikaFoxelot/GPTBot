import Foundation

// Extend FileManager to handle safe file operations
extension FileManager {
    func safeAppendToFile(url: URL, contents: String, truncateFirst: Bool = false) throws {
        try FileHandle(forWritingTo: url).use { fileHandle in
            if truncateFirst {
                fileHandle.truncateFile(atOffset: 0)
            }
            if let data = contents.data(using: .utf8) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            }
        }
    }
}

// Extend FileHandle to add a 'use' method for safer usage
extension FileHandle {
    func use(_ closure: (FileHandle) throws -> Void) rethrows {
        defer { closeFile() }
        try closure(self)
    }
}
