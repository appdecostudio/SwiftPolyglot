## What is SwiftPolyglot?

SwiftPolyglot is a handy script that checks that all of your `.xcstrings` include translations for the languages you specify. If you're working on an app that supports more than one language, there's a good chance you might forget to translate new strings.

SwiftPolyglot will ensure that:
- Translations are provided for every language that you specify
- Translations are in a `translated` state

**Note:** SwiftPolyglot was created to fulfil a requirement for my apps. As such, I have only added what is needed for my use case. I welcome any and all contributions here to make SwiftPolyglot more flexible and work for even more use cases.

## Installation

### Homebrew

```
$ brew tap appdecostudio/swiftpolyglot
$ brew install swiftpolyglot
```

### Mint

```
$ mint install appdecostudio/SwiftPolyglot
```

### Build from Source

```
$ git clone https://github.com/appdecostudio/SwiftPolyglot
$ cd SwiftPolyglot
$ swift build -c release
```

## Usage

### With a Configuration File (Recommended)

Run `swiftpolyglot init` in your project directory to generate a `.swiftpolyglot.json` configuration file. This will automatically detect the languages used in your existing `.xcstrings` files:

```
$ cd /path/to/your/project
$ swiftpolyglot init
Detected languages: de, en, es, fr
Created .swiftpolyglot.json
```

The generated `.swiftpolyglot.json` file looks like this:

```json
{
  "errorOnMissing" : false,
  "languages" : [
    "de",
    "en",
    "es",
    "fr"
  ]
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `languages` | `[String]` | Yes | Language codes to validate |
| `errorOnMissing` | `Bool` | No | Whether to exit with an error when translations are missing (default: `false`) |

Once you have a configuration file, simply run:

```
$ swiftpolyglot
```

### With CLI Arguments

You can also pass language codes directly as arguments:

```
$ swiftpolyglot en es de
```

CLI arguments take precedence over the configuration file. Use `--ignore-config` to skip the configuration file entirely:

```
$ swiftpolyglot --ignore-config en es
```

### Arguments

You must specify at least one language code (via arguments or config file), and they must be separated by spaces. If you are not providing a translation for your language of origin, you do not need to specify that language. Otherwise, you will get errors due to missing translations.

By default, SwiftPolyglot will not throw an error at the end of the script if there are translations missing. However, you can enable error throwing by adding the flag `--error-on-missing` or setting `"errorOnMissing": true` in your configuration file.

## Integrating with GitHub Actions

### Using Homebrew

```yaml
name: Run SwiftPolyglot

on:
  pull_request:
    types: [synchronize, opened, reopened, labeled, unlabeled, edited]

jobs:
  main:
    name: Validate Translations
    runs-on: macOS-latest
    steps:
      - name: git checkout
        uses: actions/checkout@v3

      - name: Install SwiftPolyglot
        run: |
          brew tap appdecostudio/swiftpolyglot
          brew install swiftpolyglot

      - name: Validate translations
        run: swiftpolyglot --error-on-missing
```

### Building from Source

```yaml
name: Run SwiftPolyglot

on:
  pull_request:
    types: [synchronize, opened, reopened, labeled, unlabeled, edited]

jobs:
  main:
    name: Validate Translations
    runs-on: macOS-latest
    steps:
      - name: git checkout
        uses: actions/checkout@v3

      - name: Clone SwiftPolyglot
        run: git clone https://github.com/appdecostudio/SwiftPolyglot.git --branch=v2.0.2 ../SwiftPolyglot

      - name: Validate translations
        run: |
          swift build --package-path ../SwiftPolyglot --configuration release
          swift run --package-path ../SwiftPolyglot swiftpolyglot es fr de it --error-on-missing
```
