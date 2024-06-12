struct MissingTranslation {
    enum Category {
        case deviceMissingOrNotTranslated(forDevice: String, inLanguage: String)
        case missingOrNotTranslated(inLanguage: String)
        case missingTranslation(forLanguage: String)
        case missingTranslationForAllLanguages
        case pluralMissingOrNotTranslated(forPluralForm: String, inLanguage: String)
    }

    let category: Category
    let filePath: String
    let originalString: String
}

extension MissingTranslation {
    var message: String {
        switch category {
            case let .deviceMissingOrNotTranslated(device, language):
                return "'\(originalString)' device '\(device)' is missing or not translated in '\(language)' in file: \(filePath)"
            case let .missingOrNotTranslated(language):
                return "'\(originalString)' is missing or not translated in '\(language)' in file: \(filePath)"
            case let .missingTranslation(language):
                return "'\(originalString)' is missing translations for language '\(language)' in file: \(filePath)"
            case .missingTranslationForAllLanguages:
                return "'\(originalString)' is not translated in any language in file: \(filePath)"
            case let .pluralMissingOrNotTranslated(pluralForm, language):
                return "'\(originalString)' plural form '\(pluralForm)' is missing or not translated in '\(language)' in file: \(filePath)"
        }
    }
}
