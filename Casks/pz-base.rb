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

  caveats <<~EOS
    Register this Mac and start it in the background:
      pz-base

    It prompts for an enrollment token. Get one from the Bases page in PlayerZero:
      https://playerzero.ai/current-org/settings/bases

    Upgrade with `brew upgrade --cask pz-base`; the agents re-register themselves afterwards.
    Stop the agents before removing it:
      pz-base stop

    Already running Base from the curl installer? This cask takes its agents over and replaces
    its auto-update with `brew upgrade`.
  EOS
end
