import ArgumentParser
import Foundation
import SwiftPolyglotCore

@main
struct SwiftPolyglot: ParsableCommand {
    func run() throws {
        guard
            let enumerator = FileManager.default.enumerator(atPath: FileManager.default.currentDirectoryPath),
            let filePaths = enumerator.allObjects as? [String]
        else {
            throw RuntimeError.fileListingNotPossible
        }

        do {
            let swiftPolyglotCore: SwiftPolyglotCore = try .init(
                arguments: Array(CommandLine.arguments.dropFirst()),
                filePaths: filePaths,
                runningOnAGitHubAction: ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true"
            )

            try swiftPolyglotCore.run()
        } catch {
            throw RuntimeError.coreError(description: error.localizedDescription)
        }
    }
}
