import ArgumentParser

@main
struct SwiftPolyglot: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "swiftpolyglot",
        abstract: "Validate .xcstrings translation files for completeness.",
        version: "1.1.0",
        subcommands: [ValidateCommand.self, InitCommand.self],
        defaultSubcommand: ValidateCommand.self
    )
}
