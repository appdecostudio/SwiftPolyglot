import Foundation

public struct SwiftPolyglot {
    private let arguments: [String]
    private let filePaths: [String]

    public init(arguments: [String], filePaths: [String]) {
        self.arguments = arguments
        self.filePaths = filePaths
    }

    public func run() throws {
        guard !arguments.isEmpty else {
            throw SwiftPolyglotError.noLanguageCodes
        }

        let isRunningFromGitHubActions = ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true"
        let languages = arguments[0].split(separator: ",").map(String.init)
        let errorOnMissing = arguments.contains("--errorOnMissing")

        var missingTranslations = false

        func checkTranslations(in fileURL: URL, for languages: [String]) throws {
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
                    guard let languageDict = localizations[lang] else {
                        logWarning(file: fileURL.path, message: "'\(originalString)' is missing translations for language: \(lang) in file: \(fileURL.path)")
                        missingTranslations = true
                        continue
                    }

                    if let variations = languageDict["variations"] as? [String: [String: [String: Any]]] {
                        try checkVariations(variations: variations, originalString: originalString, lang: lang, fileURL: fileURL)
                    } else if let stringUnit = languageDict["stringUnit"] as? [String: Any],
                              let state = stringUnit["state"] as? String, state != "translated"
                    {
                        logWarning(file: fileURL.path, message: "'\(originalString)' is missing or not translated in \(lang).")
                        missingTranslations = true
                    }
                }
            }
        }

        func checkVariations(variations: [String: [String: [String: Any]]], originalString: String, lang: String, fileURL: URL) throws {
            for (variationKey, variationDict) in variations {
                if variationKey == "plural" {
                    checkPluralizations(pluralizations: variationDict, originalString: originalString, lang: lang, fileURL: fileURL)
                } else if variationKey == "device" {
                    checkDeviceVariations(devices: variationDict, originalString: originalString, lang: lang, fileURL: fileURL)
                } else {
                    throw SwiftPolyglotError.unsupportedVariation(variation: variationKey)
                }
            }
        }

        func checkPluralizations(pluralizations: [String: [String: Any]], originalString: String, lang: String, fileURL: URL) {
            for (pluralForm, value) in pluralizations {
                guard let stringUnit = value["stringUnit"] as? [String: Any],
                      let state = stringUnit["state"] as? String, state == "translated"
                else {
                    logWarning(file: fileURL.path, message: "'\(originalString)' plural form '\(pluralForm)' is missing or not translated in \(lang) in file: \(fileURL.path)")
                    missingTranslations = true
                    continue
                }
            }
        }

        func checkDeviceVariations(devices: [String: [String: Any]], originalString: String, lang: String, fileURL: URL) {
            for (device, value) in devices {
                guard let stringUnit = value["stringUnit"] as? [String: Any],
                      let state = stringUnit["state"] as? String, state == "translated"
                else {
                    logWarning(file: fileURL.path, message: "'\(originalString)' device '\(device)' is missing or not translated in \(lang) in file: \(fileURL.path)")
                    missingTranslations = true
                    continue
                }
            }
        }

        func searchDirectory() throws {
            for filePath in filePaths {
                if filePath.hasSuffix(".xcstrings") {
                    let fileURL = URL(fileURLWithPath: filePath)
                    try checkTranslations(in: fileURL, for: languages)
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

        try searchDirectory()

        if missingTranslations, errorOnMissing {
            throw SwiftPolyglotError.missingTranslations
        } else if missingTranslations {
            print("Completed with missing translations.")
        } else {
            print("All translations are present.")
        }
    }
}
