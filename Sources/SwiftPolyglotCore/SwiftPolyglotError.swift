import Foundation

enum SwiftPolyglotError: Error {
    case missingTranslations
    case noLanguageCodes
}

extension SwiftPolyglotError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingTranslations:
            "Error: One or more translations are missing."
        case .noLanguageCodes:
            "Usage: script.swift <language codes> [--errorOnMissing]"
        }
    }
}
