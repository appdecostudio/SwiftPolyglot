import ArgumentParser
import Foundation
import SwiftPolyglotCore

struct InitCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "init",
        abstract: "Create a \(SwiftPolyglotConfig.fileName) configuration file."
    )

    @Flag(help: "Overwrite an existing configuration file.")
    private var force = false

    func run() throws {
        let configPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(SwiftPolyglotConfig.fileName)

        if FileManager.default.fileExists(atPath: configPath.path), !force {
            throw RuntimeError.configFileAlreadyExists
        }

        let filePaths = try FileEnumeration.enumerateFiles()

        let absolutePaths = filePaths.map { filePath in
            URL(fileURLWithPath: filePath, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)).path
        }

        let detectedLanguages = SwiftPolyglotConfig.detectTranslatedLanguages(in: absolutePaths)

        if detectedLanguages.isEmpty {
            print("No translated languages found. Creating a template configuration file.")
        } else {
            print("Detected languages: \(detectedLanguages.joined(separator: ", "))")
        }

        let config = SwiftPolyglotConfig(
            languages: detectedLanguages,
            errorOnMissing: false
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)

        try data.write(to: configPath)
        print("Created \(SwiftPolyglotConfig.fileName)")
    }
}
