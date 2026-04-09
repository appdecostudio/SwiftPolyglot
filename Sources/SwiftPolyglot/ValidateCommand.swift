import ArgumentParser
import Foundation
import SwiftPolyglotCore

struct ValidateCommand: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "validate",
        abstract: "Validate that .xcstrings files contain all required translations."
    )

    @Flag(help: "Log errors instead of warnings for missing translations.")
    private var errorOnMissing = false

    @Flag(help: "Ignore the .swiftpolyglot.json configuration file.")
    private var ignoreConfig = false

    @Argument(help: "Specify the language(s) to be checked.")
    private var languages: [String] = []

    func run() async throws {
        let config: SwiftPolyglotConfig? = ignoreConfig ? nil : try loadConfig()

        let resolvedLanguages = languages.isEmpty ? (config?.languages ?? []) : languages
        let resolvedErrorOnMissing = languages.isEmpty ? (config?.errorOnMissing ?? errorOnMissing) : errorOnMissing

        guard !resolvedLanguages.isEmpty else {
            throw RuntimeError.noLanguagesSpecified
        }

        let filePaths = try FileEnumeration.enumerateFiles()

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: filePaths,
            languageCodes: resolvedLanguages,
            logsErrorOnMissingTranslation: resolvedErrorOnMissing,
            isRunningInAGitHubAction: ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true"
        )

        do {
            try await swiftPolyglotCore.run()
        } catch {
            throw RuntimeError.coreError(description: error.localizedDescription)
        }
    }

    private func loadConfig() throws -> SwiftPolyglotConfig? {
        do {
            return try SwiftPolyglotConfig.load()
        } catch {
            throw RuntimeError.coreError(description: error.localizedDescription)
        }
    }
}
