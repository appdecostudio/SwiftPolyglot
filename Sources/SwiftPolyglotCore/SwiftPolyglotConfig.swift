import Foundation

public struct SwiftPolyglotConfig: Codable, Equatable {
    public let languages: [String]
    public let errorOnMissing: Bool?

    public init(languages: [String], errorOnMissing: Bool? = nil) {
        self.languages = languages
        self.errorOnMissing = errorOnMissing
    }

    public static let fileName = ".swiftpolyglot.json"

    public static func load(from directory: String = FileManager.default.currentDirectoryPath) throws -> SwiftPolyglotConfig? {
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let config = try JSONDecoder().decode(SwiftPolyglotConfig.self, from: data)

        guard !config.languages.isEmpty else {
            throw SwiftPolyglotConfigError.emptyLanguages
        }

        return config
    }

    public static func detectTranslatedLanguages(in filePaths: [String]) -> [String] {
        var languages: Set<String> = []

        for filePath in filePaths where filePath.hasSuffix(".xcstrings") {
            let fileURL = URL(fileURLWithPath: filePath)

            guard
                let data = try? Data(contentsOf: fileURL),
                let jsonObject = try? JSONSerialization.jsonObject(with: data),
                let jsonDict = jsonObject as? [String: Any],
                let strings = jsonDict["strings"] as? [String: [String: Any]]
            else {
                continue
            }

            for (_, translations) in strings {
                guard let localizations = translations["localizations"] as? [String: [String: Any]] else {
                    continue
                }

                for (lang, localization) in localizations {
                    if let stringUnit = localization["stringUnit"] as? [String: Any],
                       let state = stringUnit["state"] as? String,
                       state == "translated"
                    {
                        languages.insert(lang)
                    } else if let variations = localization["variations"] as? [String: [String: [String: Any]]] {
                        for (_, variationDict) in variations {
                            for (_, value) in variationDict {
                                if let stringUnit = value["stringUnit"] as? [String: Any],
                                   let state = stringUnit["state"] as? String,
                                   state == "translated"
                                {
                                    languages.insert(lang)
                                }
                            }
                        }
                    }
                }
            }
        }

        return languages.sorted()
    }
}

public enum SwiftPolyglotConfigError: LocalizedError {
    case emptyLanguages
    case configFileNotFound

    public var errorDescription: String? {
        switch self {
            case .emptyLanguages:
                "The \(SwiftPolyglotConfig.fileName) file must contain at least one language in the \"languages\" array."
            case .configFileNotFound:
                "No \(SwiftPolyglotConfig.fileName) file found in the current directory."
        }
    }
}
