# Template rendered by scripts/release/compose-cask.sh from the signed release manifest: edit the
# shape here, never the version or the digest.
cask "pz-base" do
  version "0.4.3"
  sha256 "583175698fd0794fe0e5d98eb2d34db951b7cea8e3459b966c8cf36433599e78"

  url "https://packages.playerzero.app/macos/releases/0.4.3/pz-base-0.4.3-aarch64-apple-darwin.dmg"
  name "PlayerZero Base"
  desc "PlayerZero Base local executor"
  homepage "https://playerzero.ai"

  depends_on arch: :arm64

  app "PlayerZero Base.app"
  # All three, because registering the service looks for the tray and the updater as siblings of
  # the pz-base it was invoked as.
  binary "#{appdir}/PlayerZero Base.app/Contents/MacOS/pz-base"
  binary "#{appdir}/PlayerZero Base.app/Contents/MacOS/pz-base-tray"
  binary "#{appdir}/PlayerZero Base.app/Contents/MacOS/pz-base-update"

  # No `auto_updates`: `pz-base update apply` refuses an executable outside the managed tree, so
  # declaring self-update would stop Homebrew upgrading a package with no other upgrade path.
  caveats <<~EOS
    Register this Mac and start it in the background:
      pz-base

    It prompts for an enrollment token. Get one from the Bases page in PlayerZero:
      https://playerzero.ai/current-org/settings/bases

    Upgrade with `brew upgrade --cask pz-base`. Stop the agents before removing it:
      pz-base stop
  EOS

  uninstall quit:      "ai.playerzero.base",
            launchctl: [
              "app.playerzero.base",
              "app.playerzero.base.tray",
              "app.playerzero.base.update",
            ]

  # `~/.pz` is absent: it holds the enrollment identity and the job ledger, which this cask did not
  # create.
  zap trash: [
    "~/Library/LaunchAgents/app.playerzero.base.plist",
    "~/Library/LaunchAgents/app.playerzero.base.tray.plist",
    "~/Library/LaunchAgents/app.playerzero.base.update.plist",
    "~/Library/Logs/playerzero-base",
  ]
end
