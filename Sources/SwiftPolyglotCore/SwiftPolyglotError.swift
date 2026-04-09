import Foundation

enum SwiftPolyglotError: Error {
    case missingTranslations
    case unsupportedVariation(variation: String)
}

extension SwiftPolyglotError: Equatable {}

extension SwiftPolyglotError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .missingTranslations:
                "Error: One or more translations are missing."
            case let .unsupportedVariation(variation):
                "Variation type '\(variation)' is not supported. Please create an issue in GitHub"
        }
    }
}
