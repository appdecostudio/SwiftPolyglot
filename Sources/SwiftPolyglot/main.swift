import Foundation

guard CommandLine.arguments.count > 1 else {
	print("Usage: script.swift <language codes> [--errorOnMissing]")
	exit(1)
}

let languages = CommandLine.arguments[1].split(separator: ",").map(String.init)
let errorOnMissing = CommandLine.arguments.contains("--errorOnMissing")

let fileManager = FileManager.default
let currentDirectoryPath = fileManager.currentDirectoryPath

var missingTranslations = false

func checkTranslations(in fileURL: URL, for languages: [String]) {
	guard let data = try? Data(contentsOf: fileURL),
	      let jsonObject = try? JSONSerialization.jsonObject(with: data),
	      let jsonDict = jsonObject as? [String: Any],
	      let strings = jsonDict["strings"] as? [String: [String: Any]]
	else {
		print("Could not process file: \(fileURL.path)")
		return
	}

	for (originalString, translations) in strings {
		guard let localizations = translations["localizations"] as? [String: [String: Any]] else {
			print("Warning: '\(originalString)' is not translated in any language in file: \(fileURL.absoluteString)")
			missingTranslations = true
			continue
		}

		for lang in languages {
			if let langDict = localizations[lang],
			   let stringUnit = langDict["stringUnit"] as? [String: Any],
			   let state = stringUnit["state"] as? String, state == "translated"
			{
			} else {
				print("Warning: '\(originalString)' is missing or not translated in \(lang) in file: \(fileURL.absoluteString)")
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

searchDirectory(currentDirectoryPath)

if missingTranslations, errorOnMissing {
	print("Error: One or more translations are missing.")
	exit(1)
} else if missingTranslations {
	print("Completed with missing translations.")
} else {
	print("All translations are present.")
}
