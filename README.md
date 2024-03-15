## What is SwiftPolyglot?

SwiftPolyglot is a handy script that checks that all of your `.xcstrings` include translations for the languages you specify. If you're working on an app that supports more than one language, there's a good chance you might forget to translate new strings.

SwiftPolyglot will ensure that:
- Translations are provided for every language that you specify
- Translations are in a `translated` state

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




