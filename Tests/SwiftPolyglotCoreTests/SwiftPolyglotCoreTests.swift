import Foundation
@testable import SwiftPolyglotCore
import Testing

struct SwiftPolyglotCoreTests {
    @Test func `string catalog fully translated`() async throws {
        let stringCatalogFilePath = try #require(
            Bundle.module.path(
                forResource: "FullyTranslated",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        )

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["ca", "de", "en", "es"],
            logsErrorOnMissingTranslation: false,
            isRunningInAGitHubAction: false
        )

        try await swiftPolyglotCore.run()
    }

    @Test func `string catalog with dont translate`() async throws {
        let stringCatalogFilePath = try #require(
            Bundle.module.path(
                forResource: "WithDontTranslate",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        )

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["de", "en"],
            logsErrorOnMissingTranslation: true,
            isRunningInAGitHubAction: false
        )

        try await swiftPolyglotCore.run()
    }

    @Test func `string catalog variations fully translated`() async throws {
        let stringCatalogFilePath = try #require(
            Bundle.module.path(
                forResource: "VariationsFullyTranslated",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        )

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["ca", "de", "en", "es"],
            logsErrorOnMissingTranslation: false,
            isRunningInAGitHubAction: false
        )

        try await swiftPolyglotCore.run()
    }

    @Test func `string catalog with missing translations`() async throws {
        let stringCatalogFilePath = try #require(
            Bundle.module.path(
                forResource: "WithMissingTranslations",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        )

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["ca", "de", "en", "es"],
            logsErrorOnMissingTranslation: true,
            isRunningInAGitHubAction: false
        )

        do {
            try await swiftPolyglotCore.run()
            Issue.record("Expected SwiftPolyglotError.missingTranslations to be thrown.")
        } catch SwiftPolyglotError.missingTranslations {
            // Expected
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }

    @Test func `string catalog with missing variations`() async throws {
        let stringCatalogFilePath = try #require(
            Bundle.module.path(
                forResource: "VariationsWithMissingTranslations",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        )

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["de, en"],
            logsErrorOnMissingTranslation: true,
            isRunningInAGitHubAction: false
        )

        do {
            try await swiftPolyglotCore.run()
            Issue.record("Expected SwiftPolyglotError.missingTranslations to be thrown.")
        } catch SwiftPolyglotError.missingTranslations {
            // Expected
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }
}
