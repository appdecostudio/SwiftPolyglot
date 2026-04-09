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
