import Foundation

public struct SwiftPolyglotCore {
    private let filePaths: [String]
    private let languageCodes: [String]
    private let logsErrorOnMissingTranslation: Bool
    private let runningOnAGitHubAction: Bool

    public init(filePaths: [String], languageCodes: [String], logsErrorOnMissingTranslation: Bool, runningOnAGitHubAction: Bool) {
        self.filePaths = filePaths
        self.languageCodes = languageCodes
        self.logsErrorOnMissingTranslation = logsErrorOnMissingTranslation
        self.runningOnAGitHubAction = runningOnAGitHubAction
    }

    public func run() throws {
        var missingTranslations = false

        try searchDirectory(for: languageCodes, missingTranslations: &missingTranslations)

        if missingTranslations, logsErrorOnMissingTranslation {
            throw SwiftPolyglotError.missingTranslations
        } else if missingTranslations {
            print("Completed with missing translations.")
        } else {
            print("All translations are present.")
        }
    }

    private func checkDeviceVariations(
        devices: [String: [String: Any]],
        originalString: String,
        lang: String,
        fileURL: URL,
        missingTranslations: inout Bool
    ) {
        for (device, value) in devices {
            guard let stringUnit = value["stringUnit"] as? [String: Any],
                  let state = stringUnit["state"] as? String, state == "translated"
            else {
                logWarning(
                    file: fileURL.path,
                    message: "'\(originalString)' device '\(device)' is missing or not translated in \(lang) in file: \(fileURL.path)"
                )
                missingTranslations = true
                continue
            }
        }
    }

    private func checkPluralizations(
        pluralizations: [String: [String: Any]],
        originalString: String,
        lang: String,
        fileURL: URL,
        missingTranslations: inout Bool
    ) {
        for (pluralForm, value) in pluralizations {
            guard let stringUnit = value["stringUnit"] as? [String: Any],
                  let state = stringUnit["state"] as? String, state == "translated"
            else {
                logWarning(
                    file: fileURL.path,
                    message: "'\(originalString)' plural form '\(pluralForm)' is missing or not translated in \(lang) in file: \(fileURL.path)"
                )
                missingTranslations = true
                continue
            }
        }
    }

    private func checkTranslations(in fileURL: URL, for languages: [String], missingTranslations: inout Bool) throws {
        guard let data = try? Data(contentsOf: fileURL),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let jsonDict = jsonObject as? [String: Any],
              let strings = jsonDict["strings"] as? [String: [String: Any]]
        else {
            if runningOnAGitHubAction {
                print("::warning file=\(fileURL.path)::Could not process file at path: \(fileURL.path)")
            } else {
                print("Could not process file at path: \(fileURL.path)")
            }
            return
        }

        for (originalString, translations) in strings {
            guard let localizations = translations["localizations"] as? [String: [String: Any]] else {
                logWarning(
                    file: fileURL.path,
                    message: "'\(originalString)' is not translated in any language in file: \(fileURL.path)"
                )
                missingTranslations = true
                continue
            }

            for lang in languages {
                guard let languageDict = localizations[lang] else {
                    logWarning(
                        file: fileURL.path,
                        message: "'\(originalString)' is missing translations for language: \(lang) in file: \(fileURL.path)"
                    )
                    missingTranslations = true
                    continue
                }

                if let variations = languageDict["variations"] as? [String: [String: [String: Any]]] {
                    try checkVariations(
                        variations: variations,
                        originalString: originalString,
                        lang: lang,
                        fileURL: fileURL,
                        missingTranslations: &missingTranslations
                    )
                } else if let stringUnit = languageDict["stringUnit"] as? [String: Any],
                          let state = stringUnit["state"] as? String, state != "translated"
                {
                    logWarning(
                        file: fileURL.path,
                        message: "'\(originalString)' is missing or not translated in \(lang) in file: \(fileURL.path)"
                    )
                    missingTranslations = true
                }
            }
        }
    }

    private func checkVariations(
        variations: [String: [String: [String: Any]]],
        originalString: String,
        lang: String,
        fileURL: URL,
        missingTranslations: inout Bool
    ) throws {
        for (variationKey, variationDict) in variations {
            if variationKey == "plural" {
                checkPluralizations(
                    pluralizations: variationDict,
                    originalString: originalString,
                    lang: lang,
                    fileURL: fileURL,
                    missingTranslations: &missingTranslations
                )
            } else if variationKey == "device" {
                checkDeviceVariations(
                    devices: variationDict,
                    originalString: originalString,
                    lang: lang,
                    fileURL: fileURL,
                    missingTranslations: &missingTranslations
                )
            } else {
                throw SwiftPolyglotError.unsupportedVariation(variation: variationKey)
            }
        }
    }
    
    private func logWarning(file: String, message: String) {
        if runningOnAGitHubAction {
            if logsErrorOnMissingTranslation {
                print("::error file=\(file)::\(message)")
            } else {
                print("::warning file=\(file)::\(message)")
            }
        } else {
            print(message)
        }
    }

    private func searchDirectory(for languages: [String], missingTranslations: inout Bool) throws {
        for filePath in filePaths {
            if filePath.hasSuffix(".xcstrings") {
                let fileURL = URL(fileURLWithPath: filePath)
                try checkTranslations(in: fileURL, for: languages, missingTranslations: &missingTranslations)
            }
        }
    }
}
