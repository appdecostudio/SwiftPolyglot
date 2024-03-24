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
            filePaths: [stringCatalogFilePath]
        )

        XCTAssertNoThrow(try swiftPolyglot.run())
    }
}

