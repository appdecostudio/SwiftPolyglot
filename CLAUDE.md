# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftPolyglot is a macOS CLI tool that validates Xcode String Catalog (`.xcstrings`) files to verify all required language translations are present and marked as "translated". It integrates with GitHub Actions for CI output formatting.

## Build & Test Commands

```bash
# Build
swift build

# Build release (universal binary)
swift build -c release --arch arm64 --arch x86_64

# Run all tests
swift test

# Run tests via xcodebuild (matches CI)
xcodebuild test -scheme SwiftPolyglotCoreTests -destination 'platform=macOS'

# Run a single test
swift test --filter SwiftPolyglotCoreTests.testFunctionName

# Run the tool locally (from a project with .xcstrings files)
swiftpolyglot en es de
swiftpolyglot --error-on-missing en es de
swiftpolyglot init          # generate .swiftpolyglot.json from existing .xcstrings files
swiftpolyglot               # validate using .swiftpolyglot.json config

# Lint (SwiftFormat)
swiftformat --lint .
```

## Architecture

Two-target SPM package with subcommands:

- **SwiftPolyglot** (executable): CLI entry point using `ArgumentParser` with subcommands. Root command in `SwiftPolyglot.swift` registers `ValidateCommand` (default) and `InitCommand`.
- **SwiftPolyglotCore** (library): All validation logic and config file parsing. No CLI dependency.

### CLI Subcommands
- `ValidateCommand` (default, runs when no subcommand specified): Loads `.swiftpolyglot.json` config, merges with CLI args (CLI overrides config), delegates to `SwiftPolyglotCore`. Flags: `--error-on-missing`, `--ignore-config`.
- `InitCommand`: Scans `.xcstrings` files in CWD to auto-detect languages, writes `.swiftpolyglot.json`. Flag: `--force` to overwrite.

### Core Types
- `SwiftPolyglotCore` — orchestrates file discovery, JSON parsing, and validation. Entry point is `run() async throws`.
- `SwiftPolyglotConfig` — `Codable` struct representing `.swiftpolyglot.json`. Static `load(from:)` method returns `nil` if no file found, throws on malformed/invalid config.
- `MissingTranslation` — represents a validation failure with a `Category` enum covering: missing for all languages, missing for specific language, untranslated strings, and plural/device variation gaps.
- `SwiftPolyglotError` — domain errors (`missingTranslations`, `unsupportedVariation`).

Strings with `shouldTranslate` set to `false` in the catalog are skipped.

## Config File

`.swiftpolyglot.json` in the project root:
```json
{
  "languages": ["en", "es", "de"],
  "errorOnMissing": true
}
```

## Code Style

SwiftFormat is enforced via Danger on PRs. Key settings: 4-space indent, `--indentcase true`, `--commas always`, Swift 5.7 target.

## Releasing

Push a tag (`v1.2.0`) to trigger `.github/workflows/release.yml`, which builds a universal macOS binary and creates a GitHub Release. The Homebrew formula in `Formula/swiftpolyglot.rb` needs its sha256 updated after each release.
