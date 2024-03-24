import Foundation
import SwiftPolyglotCore

guard
    let enumerator = FileManager.default.enumerator(atPath: FileManager.default.currentDirectoryPath),
    let filePaths = enumerator.allObjects as? [String]
else {
    exit(EXIT_FAILURE)
}

let swiftPolyglot: SwiftPolyglot = .init(
    arguments: Array(CommandLine.arguments.dropFirst()),
    filePaths: filePaths
)

do {
    try swiftPolyglot.run()
} catch {
    print(error)
}
