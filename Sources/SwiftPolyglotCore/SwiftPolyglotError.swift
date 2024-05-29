import Foundation

enum SwiftPolyglotError: Error {
    case missingTranslations
    case unsupportedVariation(variation: String)
}

extension SwiftPolyglotError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .missingTranslations:
                return "Error: One or more translations are missing."
            case let .unsupportedVariation(variation):
                return "Variation type '\(variation)' is not supported. Please create an issue in GitHub"
        }
    }
}
