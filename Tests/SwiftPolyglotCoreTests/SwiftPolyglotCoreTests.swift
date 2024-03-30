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

        let swiftPolyglot: SwiftPolyglot = .init(
            arguments: ["ca,de,en,es"],
            filePaths: [stringCatalogFilePath],
            runningOnAGitHubAction: false
        )

        XCTAssertNoThrow(try swiftPolyglot.run())
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

        let swiftPolyglot: SwiftPolyglot = .init(
            arguments: ["ca,de,en,es"],
            filePaths: [stringCatalogFilePath],
            runningOnAGitHubAction: false
        )

        XCTAssertNoThrow(try swiftPolyglot.run())
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

        let swiftPolyglot: SwiftPolyglot = .init(
            arguments: ["ca,de,en,es", "--errorOnMissing"],
            filePaths: [stringCatalogFilePath],
            runningOnAGitHubAction: false
        )

        XCTAssertThrowsError(try swiftPolyglot.run())
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

        let swiftPolyglot: SwiftPolyglot = .init(
            arguments: ["de,en", "--errorOnMissing"],
            filePaths: [stringCatalogFilePath],
            runningOnAGitHubAction: false
        )

        XCTAssertThrowsError(try swiftPolyglot.run())
    }
}
