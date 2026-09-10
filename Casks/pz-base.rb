# Template rendered by scripts/release/compose-cask.sh from the signed release manifest: edit the
# shape here, never the version or the digest.
cask "pz-base" do
  version "0.4.1"
  sha256 "ec51791c42c6d85ed01bffd53e9db9a453c9ebc5f3537798b22d7b6a72d7a324"

  url "https://packages.playerzero.app/macos/releases/0.4.1/pz-base-0.4.1-aarch64-apple-darwin.dmg"
  name "PlayerZero Base"
  desc "PlayerZero Base local executor"
  homepage "https://playerzero.ai"

  depends_on arch: :arm64

  app "PlayerZero Base.app"
  # All three, because `pz-base service install` looks for the tray and the updater as siblings of
  # the pz-base it was invoked as.
  binary "#{appdir}/PlayerZero Base.app/Contents/MacOS/pz-base"
  binary "#{appdir}/PlayerZero Base.app/Contents/MacOS/pz-base-tray"
  binary "#{appdir}/PlayerZero Base.app/Contents/MacOS/pz-base-update"

  # No `auto_updates`: `pz-base update apply` refuses an executable outside the managed tree, so
  # declaring self-update would stop Homebrew upgrading a package with no other upgrade path.
  caveats <<~EOS
    Enroll this Base, then register the user agents:
      pz-base enroll
      pz-base service install

    Upgrade with `brew upgrade --cask pz-base`. Stop the agents before removing it:
      pz-base service uninstall
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
