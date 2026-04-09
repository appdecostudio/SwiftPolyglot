import Foundation

enum FileEnumeration {
    private static let excludedDirectories: Set<String> = [
        ".build",
        ".git",
        ".swiftpm",
        "Pods",
        "Carthage",
        "DerivedData",
        ".deriveddata",
        "SourcePackages",
    ]

    static func enumerateFiles() throws -> [String] {
        let currentDirectory = FileManager.default.currentDirectoryPath

        guard
            let enumerator = FileManager.default.enumerator(atPath: currentDirectory),
            let filePaths = enumerator.allObjects as? [String]
        else {
            throw RuntimeError.fileListingNotPossible
        }

        return filePaths.filter { filePath in
            let components = filePath.split(separator: "/").map(String.init)
            return !components.contains(where: { excludedDirectories.contains($0) })
        }
    }
}
