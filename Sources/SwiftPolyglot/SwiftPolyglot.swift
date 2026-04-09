import ArgumentParser

@main
struct SwiftPolyglot: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "swiftpolyglot",
        abstract: "Validate .xcstrings translation files for completeness.",
        version: "2.0.2",
        subcommands: [ValidateCommand.self, InitCommand.self],
        defaultSubcommand: ValidateCommand.self
    )
}
