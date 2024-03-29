## What is SwiftPolyglot?

SwiftPolyglot is a handy script that checks that all of your `.xcstrings` include translations for the languages you specify. If you're working on an app that supports more than one language, there's a good chance you might forget to translate new strings.

SwiftPolyglot will ensure that:
- Translations are provided for every language that you specify
- Translations are in a `translated` state

**Note:** SwiftPolyglot was created to fulfil a requirement for my apps. As such, I have only added what is needed for my use case. I welcome any and all contributions here to make SwiftPolyglot more flexible and work for even more use cases.

## Installation

Right now, SwiftPolyglot can only be used from the command line. This gives you the flexibility to run it manually or integrate it with another toolchain.

To do this, you'll need to follow these steps:

1. Clone the repository and build the package locally:

```
$ git clone https://github.com/appdecostudio/SwiftPolyglot
$ cd SwiftPolyglot
$ swift build -c release
```

2. Run against your project:

```
$ cd ../path/to/your/project
$ swift run --package-path ../path/to/SwiftPolyglot swiftpolyglot "en,es,de"
```

## Arguments

You must specify at least one language code, they must be within quotation marks, and they must be separated by commas. If you are not providing a translation for your language of origin, you do not need to specify that language. Otherwise, you will get errors due to missing translations.

By default, SwiftPolyglot will not throw an error at the end of the script if there are translations missing. However, you can enable error throwing by adding the argument `--errorOnMissing`

## Integrating with GitHub Actions

Here is a sample GitHub action .yml file that you can use to automatically run SwiftPolyglot. Feel free to modify this for your needs.

```
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
        run: git clone https://github.com/appdecostudio/SwiftPolyglot.git --branch=0.3.1 ../SwiftPolyglot

      - name: validate translations
        run: |
          swift build --package-path ../SwiftPolyglot --configuration release
          swift run --package-path ../SwiftPolyglot swiftpolyglot "es,fr,de,it" --errorOnMissing
```

