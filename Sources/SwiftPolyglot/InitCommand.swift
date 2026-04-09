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

        let detectedLanguages = detectLanguages()

        if detectedLanguages.isEmpty {
            print("No .xcstrings files found in the current directory. Creating a template configuration file.")
        } else {
            print("Detected languages: \(detectedLanguages.sorted().joined(separator: ", "))")
        }

        let config = SwiftPolyglotConfig(
            languages: detectedLanguages.sorted(),
            errorOnMissing: false
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)

        try data.write(to: configPath)
        print("Created \(SwiftPolyglotConfig.fileName)")
    }

    private func detectLanguages() -> [String] {
        let currentDirectory = FileManager.default.currentDirectoryPath

        guard
            let enumerator = FileManager.default.enumerator(atPath: currentDirectory),
            let filePaths = enumerator.allObjects as? [String]
        else {
            return []
        }

        var languages: Set<String> = []

        for filePath in filePaths where filePath.hasSuffix(".xcstrings") {
            let fileURL = URL(fileURLWithPath: filePath, relativeTo: URL(fileURLWithPath: currentDirectory))

            guard
                let data = try? Data(contentsOf: fileURL),
                let jsonObject = try? JSONSerialization.jsonObject(with: data),
                let jsonDict = jsonObject as? [String: Any],
                let strings = jsonDict["strings"] as? [String: [String: Any]]
            else {
                continue
            }

            for (_, translations) in strings {
                guard let localizations = translations["localizations"] as? [String: Any] else {
                    continue
                }

                for key in localizations.keys {
                    languages.insert(key)
                }
            }
        }

        return Array(languages)
    }
}
