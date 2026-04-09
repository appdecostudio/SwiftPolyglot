import Foundation
@testable import SwiftPolyglotCore
import Testing

struct SwiftPolyglotConfigTests {
    private func createTempDirectory() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }

    private func copyConfigToTempDirectory(resource: String, tempDir: URL) throws {
        let configFilePath = try #require(
            Bundle.module.path(
                forResource: resource,
                ofType: "json",
                inDirectory: "TestFiles"
            )
        )

        let destination = tempDir.appendingPathComponent(SwiftPolyglotConfig.fileName)
        try FileManager.default.copyItem(
            at: URL(fileURLWithPath: configFilePath),
            to: destination
        )
    }

    @Test func `load valid config`() throws {
        let tempDir = try createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try copyConfigToTempDirectory(resource: "ValidConfig.swiftpolyglot", tempDir: tempDir)

        let loadedConfig = try SwiftPolyglotConfig.load(from: tempDir.path)
        let config = try #require(loadedConfig)

        #expect(config.languages == ["en", "es", "de"])
        #expect(config.errorOnMissing == true)
    }

    @Test func `load minimal config`() throws {
        let tempDir = try createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try copyConfigToTempDirectory(resource: "MinimalConfig.swiftpolyglot", tempDir: tempDir)

        let loadedConfig = try SwiftPolyglotConfig.load(from: tempDir.path)
        let config = try #require(loadedConfig)

        #expect(config.languages == ["en", "fr"])
        #expect(config.errorOnMissing == nil)
    }

    @Test func `load returns nil when no file exists`() throws {
        let tempDir = try createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let config = try SwiftPolyglotConfig.load(from: tempDir.path)

        #expect(config == nil)
    }

    @Test func `load throws on malformed JSON`() throws {
        let tempDir = try createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let destination = tempDir.appendingPathComponent(SwiftPolyglotConfig.fileName)
        let data = try #require("{ not valid json".data(using: .utf8))
        try data.write(to: destination)

        #expect(throws: (any Error).self) {
            try SwiftPolyglotConfig.load(from: tempDir.path)
        }
    }

    @Test func `detect translated languages from xcstrings files`() throws {
        let fullyTranslatedPath = try #require(
            Bundle.module.path(
                forResource: "FullyTranslated",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        )

        let languages = SwiftPolyglotConfig.detectTranslatedLanguages(in: [fullyTranslatedPath])

        #expect(languages.contains("ca"))
        #expect(languages.contains("de"))
        #expect(languages.contains("en"))
        #expect(languages.contains("es"))
    }

    @Test func `detect translated languages excludes untranslated languages`() throws {
        let missingTranslationsPath = try #require(
            Bundle.module.path(
                forResource: "WithMissingTranslations",
                ofType: ".xcstrings",
                inDirectory: "TestFiles"
            )
        )

        let languages = SwiftPolyglotConfig.detectTranslatedLanguages(in: [missingTranslationsPath])

        #expect(languages.contains("de"))
        #expect(languages.contains("en"))
        #expect(languages.contains("ca") == false, "ca should be excluded — no strings are translated in ca")
        #expect(languages.contains("es") == false, "es should be excluded — no strings are translated in es")
    }

    @Test func `detect translated languages returns empty for no xcstrings files`() {
        let languages = SwiftPolyglotConfig.detectTranslatedLanguages(in: ["/nonexistent/path.xcstrings"])

        #expect(languages.isEmpty)
    }

    @Test func `load throws on empty languages`() throws {
        let tempDir = try createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try copyConfigToTempDirectory(resource: "EmptyLanguagesConfig.swiftpolyglot", tempDir: tempDir)

        #expect(throws: SwiftPolyglotConfigError.emptyLanguages) {
            try SwiftPolyglotConfig.load(from: tempDir.path)
        }
    }
}
