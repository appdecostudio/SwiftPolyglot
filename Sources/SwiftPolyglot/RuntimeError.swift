import SwiftPolyglotCore

enum RuntimeError: Error {
    case coreError(description: String)
    case fileListingNotPossible
    case noLanguagesSpecified
    case configFileAlreadyExists
}

extension RuntimeError: CustomStringConvertible {
    var description: String {
        switch self {
            case let .coreError(description):
                return description
            case .fileListingNotPossible:
                return "It was not possible to list all files to be checked"
            case .noLanguagesSpecified:
                return "No languages specified. Provide language codes as arguments or create a \(SwiftPolyglotConfig.fileName) configuration file using 'swiftpolyglot init'."
            case .configFileAlreadyExists:
                return "\(SwiftPolyglotConfig.fileName) already exists. Use --force to overwrite."
        }
    }
}
