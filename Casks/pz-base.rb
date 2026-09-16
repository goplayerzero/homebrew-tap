# Template rendered by scripts/release/compose-cask.sh from the signed release manifest: edit the
# shape here, never the version or the digest.
cask "pz-base" do
  version "0.4.7"
  sha256 "7f90ae5e52866780815b05df9e425a2c215d60f6a97cbf7bec95899a525089a4"

  url "https://packages.playerzero.app/macos/releases/0.4.7/pz-base-0.4.7-aarch64-apple-darwin.dmg"
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

    Upgrade with `brew upgrade --cask pz-base`; the agents re-register themselves afterwards.
    Stop the agents before removing it:
      pz-base stop

    Already running Base from the curl installer? This cask takes its agents over and replaces
    its auto-update with `brew upgrade`.
  EOS

  # `uninstall launchctl:` below runs on upgrade as well as removal, so without this an upgrade
  # ends with the daemon and tray unloaded and nothing to bring them back. `service start` is the
  # non-interactive route -- bare `pz-base` prompts. `--force` because the rendered units name this
  # version's executable while the ones on disk still name the last one. Advisory: a Mac that
  # cannot register its agents is still a successful install of the app.
  postflight do
    # Keyed on the config and not on the agents: `uninstall launchctl:` deletes the plists before
    # this runs, so guarding on one of those would skip the reload on every upgrade -- the case it
    # exists for. The config is what `service start` needs (it canonicalizes one before it does
    # anything, and refuses when there is none), and `~/.pz` survives an upgrade untouched. A first
    # install has no `~/.pz` at all, so the refusal is still never printed over an install that
    # worked.
    next unless File.exist?(File.expand_path("~/.pz/config.toml"))

    system_command "#{appdir}/PlayerZero Base.app/Contents/MacOS/pz-base",
                   args:         ["service", "start", "--force"],
                   must_succeed: false
  end

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
