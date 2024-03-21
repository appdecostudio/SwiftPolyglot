import SwiftPolyglotCore

let swiftPolyglot: SwiftPolyglot = .init(arguments: CommandLine.arguments)

do {
    try swiftPolyglot.run()
} catch {
    print(error)
}
