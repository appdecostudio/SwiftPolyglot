import ArgumentParser
import Foundation
import SwiftPolyglotCore

@main
struct SwiftPolyglot: ParsableCommand {
    @Flag(help: "Log errors instead of warnings for missing translations.")
    private var errorOnMissing = false

    @Argument(help: "Specify the language(s) to be checked.")
    private var languages: [String]

    func run() throws {
        guard
            let enumerator = FileManager.default.enumerator(atPath: FileManager.default.currentDirectoryPath),
            let filePaths = enumerator.allObjects as? [String]
        else {
            throw RuntimeError.fileListingNotPossible
        }

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: filePaths,
            languageCodes: languages,
            logsErrorOnMissingTranslation: errorOnMissing,
            isRunningInAGitHubAction: ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true"
        )

        do {
            try swiftPolyglotCore.run()
        } catch {
            throw RuntimeError.coreError(description: error.localizedDescription)
        }
    }
}
