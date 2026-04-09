import ArgumentParser

@main
struct SwiftPolyglot: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "swiftpolyglot",
        abstract: "Validate .xcstrings translation files for completeness.",
        version: "0.0.0-dev",
        subcommands: [ValidateCommand.self, InitCommand.self],
        defaultSubcommand: ValidateCommand.self
    )
}
