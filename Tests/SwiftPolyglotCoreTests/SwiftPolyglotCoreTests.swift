@testable import SwiftPolyglotCore
import XCTest

final class SwiftPolyglotCoreTests: XCTestCase {
    func testStringCatalogFullyTranslated() throws {
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
            runningOnAGitHubAction: false
        )

        XCTAssertNoThrow(try swiftPolyglotCore.run())
    }

    func testStringCatalogVariationsFullyTranslated() throws {
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
            runningOnAGitHubAction: false
        )

        XCTAssertNoThrow(try swiftPolyglotCore.run())
    }

    func testStringCatalogWithMissingTranslations() throws {
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
            runningOnAGitHubAction: false
        )

        XCTAssertThrowsError(try swiftPolyglotCore.run())
    }

    func testStringCatalogWithMissingVariations() throws {
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
            runningOnAGitHubAction: false
        )

        XCTAssertThrowsError(try swiftPolyglotCore.run())
    }
}
