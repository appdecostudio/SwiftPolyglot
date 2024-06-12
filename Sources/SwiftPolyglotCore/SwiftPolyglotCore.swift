import Foundation

public struct SwiftPolyglotCore {
    private let filePaths: [String]
    private let languageCodes: [String]
    private let logsErrorOnMissingTranslation: Bool
    private let isRunningInAGitHubAction: Bool

    public init(
        filePaths: [String],
        languageCodes: [String],
        logsErrorOnMissingTranslation: Bool,
        isRunningInAGitHubAction: Bool
    ) {
        self.filePaths = filePaths
        self.languageCodes = languageCodes
        self.logsErrorOnMissingTranslation = logsErrorOnMissingTranslation
        self.isRunningInAGitHubAction = isRunningInAGitHubAction
    }

    public func run() async throws {
        let stringCatalogFileURLs: [URL] = getStringCatalogURLs(from: filePaths)

        let missingTranslations: [MissingTranslation] = try await withThrowingTaskGroup(of: [MissingTranslation].self) { taskGroup in
            for fileURL in stringCatalogFileURLs {
                taskGroup.addTask {
                    let strings: [String: [String: Any]] = extractStrings(
                        from: fileURL,
                        isRunningInAGitHubAction: isRunningInAGitHubAction
                    )

                    let missingTranslations: [MissingTranslation] = try await getMissingTranslations(from: strings, in: fileURL.path)

                    let missingTranslationsLogs: [String] = missingTranslations.map { missingTranslation in
                        if isRunningInAGitHubAction {
                            return logForGitHubAction(
                                missingTranslation: missingTranslation,
                                logWithError: logsErrorOnMissingTranslation
                            )
                        } else {
                            return missingTranslation.message
                        }
                    }

                    missingTranslationsLogs.forEach { print($0) }

                    return missingTranslations
                }
            }

            return try await taskGroup.reduce(into: [MissingTranslation]()) { partialResult, missingTranslations in
                partialResult.append(contentsOf: missingTranslations)
            }
        }

        if !missingTranslations.isEmpty, logsErrorOnMissingTranslation {
            throw SwiftPolyglotError.missingTranslations
        } else if !missingTranslations.isEmpty {
            print("Completed with missing translations.")
        } else {
            print("All translations are present.")
        }
    }

    private func extractStrings(from fileURL: URL, isRunningInAGitHubAction: Bool) -> [String: [String: Any]] {
        guard
            let data = try? Data(contentsOf: fileURL),
            let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonObject as? [String: Any],
            let strings = jsonDict["strings"] as? [String: [String: Any]]
        else {
            if isRunningInAGitHubAction {
                print("::warning file=\(fileURL.path)::Could not process file at path: \(fileURL.path)")
            } else {
                print("Could not process file at path: \(fileURL.path)")
            }

            return [:]
        }

        return strings
    }

    private func getMissingTranslations(
        from strings: [String: [String: Any]],
        in filePath: String
    ) async throws -> [MissingTranslation] {
        var missingTranslations: [MissingTranslation] = []

        for (originalString, translations) in strings {
            guard let localizations = translations["localizations"] as? [String: [String: Any]] else {
                missingTranslations.append(
                    MissingTranslation(
                        category: .missingTranslationForAllLanguages,
                        filePath: filePath,
                        originalString: originalString
                    )
                )

                continue
            }

            for lang in languageCodes {
                guard let languageDict = localizations[lang] else {
                    missingTranslations.append(
                        MissingTranslation(
                            category: .missingTranslation(forLanguage: lang),
                            filePath: filePath,
                            originalString: originalString
                        )
                    )

                    continue
                }

                if let variations = languageDict["variations"] as? [String: [String: [String: Any]]] {
                    try missingTranslations.append(
                        contentsOf:
                        getMissingTranslationsFromVariations(
                            variations,
                            originalString: originalString,
                            lang: lang,
                            filePath: filePath
                        )
                    )
                } else if
                    let stringUnit = languageDict["stringUnit"] as? [String: Any],
                    let state = stringUnit["state"] as? String,
                    state != "translated"
                {
                    missingTranslations.append(
                        MissingTranslation(
                            category: .missingOrNotTranslated(inLanguage: lang),
                            filePath: filePath,
                            originalString: originalString
                        )
                    )
                }
            }
        }

        return missingTranslations
    }

    private func getMissingTranslationsFromVariations(
        _ variations: [String: [String: [String: Any]]],
        originalString: String,
        lang: String,
        filePath: String
    ) throws -> [MissingTranslation] {
        var missingTranslations: [MissingTranslation] = []

        for (variationKey, variationDict) in variations {
            if variationKey == "plural" {
                for (pluralForm, value) in variationDict {
                    guard
                        let stringUnit = value["stringUnit"] as? [String: Any],
                        let state = stringUnit["state"] as? String,
                        state == "translated"
                    else {
                        missingTranslations.append(
                            MissingTranslation(
                                category: .pluralMissingOrNotTranslated(forPluralForm: pluralForm, inLanguage: lang),
                                filePath: filePath,
                                originalString: originalString
                            )
                        )

                        continue
                    }
                }
            } else if variationKey == "device" {
                for (device, value) in variationDict {
                    guard
                        let stringUnit = value["stringUnit"] as? [String: Any],
                        let state = stringUnit["state"] as? String,
                        state == "translated"
                    else {
                        missingTranslations.append(
                            MissingTranslation(
                                category: .deviceMissingOrNotTranslated(forDevice: device, inLanguage: lang),
                                filePath: filePath,
                                originalString: originalString
                            )
                        )

                        continue
                    }
                }
            } else {
                throw SwiftPolyglotError.unsupportedVariation(variation: variationKey)
            }
        }

        return missingTranslations
    }

    private func getStringCatalogURLs(from filePaths: [String]) -> [URL] {
        filePaths.compactMap { filePath in
            guard filePath.hasSuffix(".xcstrings") else { return nil }

            return URL(fileURLWithPath: filePath)
        }
    }

    private func logForGitHubAction(missingTranslation: MissingTranslation, logWithError: Bool) -> String {
        if logWithError {
            return "::error file=\(missingTranslation.filePath)::\(missingTranslation.message)"
        } else {
            return "::warning file=\(missingTranslation.filePath)::\(missingTranslation.message)"
        }
    }
}
