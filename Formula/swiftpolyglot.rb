class Swiftpolyglot < Formula
  desc "Validate .xcstrings translation files for completeness"
  homepage "https://github.com/appdecostudio/SwiftPolyglot"
  license "MIT"
  version "1.1.0"

  url "https://github.com/appdecostudio/SwiftPolyglot/releases/download/v#{version}/swiftpolyglot-#{version}-macos.tar.gz"
  # sha256 "PLACEHOLDER - update with actual checksum from release workflow"

  depends_on :macos

  def install
    bin.install "swiftpolyglot"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/swiftpolyglot --version")
  end
end
