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
                description
            case .fileListingNotPossible:
                "It was not possible to list all files to be checked"
            case .noLanguagesSpecified:
                "No languages specified. Provide language codes as arguments or create a \(SwiftPolyglotConfig.fileName) configuration file using 'swiftpolyglot init'."
            case .configFileAlreadyExists:
                "\(SwiftPolyglotConfig.fileName) already exists. Use --force to overwrite."
        }
    }
}
