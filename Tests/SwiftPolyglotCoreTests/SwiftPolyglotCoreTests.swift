@testable import SwiftPolyglotCore
import XCTest

final class SwiftPolyglotCoreTests: XCTestCase {
    func testStringCatalogFullyTranslated() async throws {
        guard
            let stringCatalogFilePath = Bundle.module.path(
                forResource: "FullyTranslated",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        else {
            XCTFail("Fully translated string catalog for testing not found")
            return
        }

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["ca", "de", "en", "es"],
            logsErrorOnMissingTranslation: false,
            isRunningInAGitHubAction: false
        )

        await XCTAssertNoThrowAsync(swiftPolyglotCore.run)
    }

    func testStringCatalogVariationsFullyTranslated() async throws {
        guard
            let stringCatalogFilePath = Bundle.module.path(
                forResource: "VariationsFullyTranslated",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        else {
            XCTFail("Variations fully translated string catalog for testing not found")
            return
        }

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["ca", "de", "en", "es"],
            logsErrorOnMissingTranslation: false,
            isRunningInAGitHubAction: false
        )

        await XCTAssertNoThrowAsync(swiftPolyglotCore.run)
    }

    func testStringCatalogWithMissingTranslations() async throws {
        guard
            let stringCatalogFilePath = Bundle.module.path(
                forResource: "WithMissingTranslations",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        else {
            XCTFail("String catalog with missing translations for testing not found")
            return
        }

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["ca", "de", "en", "es"],
            logsErrorOnMissingTranslation: true,
            isRunningInAGitHubAction: false
        )

        await XCTAssertThrowsErrorAsync(try await swiftPolyglotCore.run())
    }

    func testStringCatalogWithMissingVariations() async throws {
        guard
            let stringCatalogFilePath = Bundle.module.path(
                forResource: "VariationsWithMissingTranslations",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        else {
            XCTFail("String catalog with missing variations translations for testing not found")
            return
        }

        let swiftPolyglotCore: SwiftPolyglotCore = .init(
            filePaths: [stringCatalogFilePath],
            languageCodes: ["de, en"],
            logsErrorOnMissingTranslation: true,
            isRunningInAGitHubAction: false
        )

        await XCTAssertThrowsErrorAsync(try await swiftPolyglotCore.run())
    }
}
