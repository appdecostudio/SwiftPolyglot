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
                return "Error: One or more translations are missing."
            case .noLanguageCodes:
                return "Usage: swiftpolyglot <comma-separated language codes> [--errorOnMissing]"
            case let .unsupportedVariation(variation):
                return "Variation type '\(variation)' is not supported. Please create an issue in GitHub"
        }
    }
}
