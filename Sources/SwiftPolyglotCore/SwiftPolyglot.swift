import Foundation

public struct SwiftPolyglot {
    private let arguments: [String]

    public init(arguments: [String]) {
        self.arguments = arguments
    }

    public func run() throws {
        guard !arguments.isEmpty else {
            print("Usage: script.swift <language codes> [--errorOnMissing]")
            exit(1)
        }

        let isRunningFromGitHubActions = ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true"
        let languages = arguments[0].split(separator: ",").map(String.init)
        let errorOnMissing = arguments.contains("--errorOnMissing")

        let fileManager = FileManager.default
        let currentDirectoryPath = fileManager.currentDirectoryPath

        var missingTranslations = false

        func checkTranslations(in fileURL: URL, for languages: [String]) {
            guard let data = try? Data(contentsOf: fileURL),
                  let jsonObject = try? JSONSerialization.jsonObject(with: data),
                  let jsonDict = jsonObject as? [String: Any],
                  let strings = jsonDict["strings"] as? [String: [String: Any]]
            else {
                if isRunningFromGitHubActions {
                    print("::warning file=\(fileURL.path)::Could not process file at path: \(fileURL.path)")
                } else {
                    print("Could not process file at path: \(fileURL.path)")
                }
                return
            }

            for (originalString, translations) in strings {
                guard let localizations = translations["localizations"] as? [String: [String: Any]] else {
                    logWarning(file: fileURL.path, message: "'\(originalString)' is not translated in any language in file: \(fileURL.path)")
                    missingTranslations = true
                    continue
                }

                for lang in languages {
                    if let langDict = localizations[lang],
                       let stringUnit = langDict["stringUnit"] as? [String: Any],
                       let state = stringUnit["state"] as? String, state == "translated"
                    {
                    } else {
                        logWarning(file: fileURL.path, message: "'\(originalString)' is missing or not translated in \(lang) in file: \(fileURL.path)")
                        missingTranslations = true
                    }
                }
            }
        }

        func searchDirectory(_ dirPath: String) {
            if let enumerator = fileManager.enumerator(atPath: dirPath) {
                for case let file as String in enumerator {
                    if file.hasSuffix(".xcstrings") {
                        let fileURL = URL(fileURLWithPath: dirPath).appendingPathComponent(file)
                        checkTranslations(in: fileURL, for: languages)
                    }
                }
            }
        }

        func logWarning(file: String, message: String) {
            if isRunningFromGitHubActions {
                if errorOnMissing {
                    print("::error file=\(file)::\(message)")
                } else {
                    print("::warning file=\(file)::\(message)")
                }
            } else {
                print(message)
            }
        }

        searchDirectory(currentDirectoryPath)

        if missingTranslations, errorOnMissing {
            print("Error: One or more translations are missing.")
            exit(1)
        } else if missingTranslations {
            print("Completed with missing translations.")
        } else {
            print("All translations are present.")
        }
    }
}
