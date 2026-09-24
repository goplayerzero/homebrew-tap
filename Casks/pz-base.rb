# Template rendered by scripts/release/compose-cask.sh from the signed release manifest: edit the
# shape here, never the version or the digest.
cask "pz-base" do
  version "0.4.12"
  sha256 "113b9ce5287f3bf5f844e89a21d1c402e48869c1ea3ce794b956f65b364e4b00"

  url "https://packages.playerzero.app/macos/releases/0.4.12/pz-base-0.4.12-aarch64-apple-darwin.pkg"
  name "PlayerZero Base"
  desc "PlayerZero Base local executor"
  homepage "https://playerzero.ai/"

  depends_on arch: :arm64
  # Not a real narrowing: no Apple silicon Mac shipped before Big Sur, so the arch constraint above
  # already implies this. Declared because the cask linter requires a macOS constraint.
  depends_on macos: :big_sur

  # An installer package rather than the app bundle, because `uninstall launchctl:` below unloads
  # the agents on an upgrade as well as a removal, and only the package can put them back: Homebrew
  # runs a cask's own install hooks inside a sandbox with no route to launchd, so the reload has to
  # happen in the package's postinstall, which the installer runs as root and unsandboxed. The
  # script is `packaging/macos/postinstall`; the disk image remains the hand-install route.
  pkg "pz-base-#{version}-aarch64-apple-darwin.pkg"
  # All three, because registering the service looks for the tray and the updater as siblings of
  # the pz-base it was invoked as. Homebrew installs `pkg` before `binary`, so these resolve.
  # Spelled out rather than `appdir`: a package installs where the package says, so a Homebrew
  # configured with another application directory would link three paths with no file behind them.
  binary "/Applications/PlayerZero Base.app/Contents/MacOS/pz-base"
  binary "/Applications/PlayerZero Base.app/Contents/MacOS/pz-base-tray"
  binary "/Applications/PlayerZero Base.app/Contents/MacOS/pz-base-update"

  # No `auto_updates`: `pz-base update apply` refuses an executable outside the managed tree, so
  # declaring self-update would stop Homebrew upgrading a package with no other upgrade path.
  uninstall launchctl: [
              "app.playerzero.base",
              "app.playerzero.base.tray",
              "app.playerzero.base.update",
            ],
            quit:      "ai.playerzero.base",
            pkgutil:   "ai.playerzero.base"

  # `~/.pz` is absent: it holds the enrollment identity and the job ledger, which this cask did not
  # create.
  zap trash: [
    "~/Library/LaunchAgents/app.playerzero.base.plist",
    "~/Library/LaunchAgents/app.playerzero.base.tray.plist",
    "~/Library/LaunchAgents/app.playerzero.base.update.plist",
    "~/Library/Logs/playerzero-base",
  ]

  # One instruction, because `pz-base` asks for everything else it needs: it prompts for the
  # enrollment token and links to the page that issues one. Anything repeated here would be read
  # after every install and every upgrade, and would be a second place to keep current.
  #
  # Boxed and coloured to match the installer Portal serves, so arriving either way looks like
  # arriving at the same product. Homebrew decides whether colour is wanted -- piped output and
  # NO_COLOR both turn it off -- and the rule is measured against the plain text, since the
  # escapes occupy no columns.
  caveats do
    instruction = "Run 'pz-base' to connect this machine to PlayerZero"
    rule = "\u2500" * (instruction.length + 2)
    orange = Tty.color? ? "\e[38;2;230;85;50m" : ""
    reset = Tty.color? ? "\e[0m" : ""
    <<~EOS
      #{orange}\u256d#{rule}\u256e#{reset}
      #{orange}\u2502#{reset} #{instruction} #{orange}\u2502#{reset}
      #{orange}\u2570#{rule}\u256f#{reset}
    EOS
  end
end
