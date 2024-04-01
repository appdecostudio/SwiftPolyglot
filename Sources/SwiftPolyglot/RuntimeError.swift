enum RuntimeError: Error {
    case coreError(description: String)
    case fileListingNotPossible
}

extension RuntimeError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .coreError(description):
            return description
        case .fileListingNotPossible:
            return "It was not possible to list all files to be checked"
        }
    }
}
