import Foundation

enum SwiftPolyglotError: Error {
    case missingTranslations
    case noLanguageCodes
    case unsupportedVariation(variation: String)
}

extension SwiftPolyglotError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .missingTranslations:
                "Error: One or more translations are missing."
            case .noLanguageCodes:
                "Usage: swiftpolyglot <comma-separated language codes> [--errorOnMissing]"
            case let .unsupportedVariation(variation):
                "Variation type '\(variation)' is not supported. Please create an issue in GitHub"
        }
    }
}
