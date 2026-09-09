# PlayerZero Homebrew tap

```shell
brew tap goplayerzero/tap
brew install --cask pz-base
pz-base enroll
pz-base service install
```

`pz-base` installs the signed, notarized PlayerZero Base app bundle and links the daemon, the tray
and the updater into the Homebrew prefix. Enrollment comes before service registration: registering
the user agents refuses to write anything until enrollment has created a policy.

A Homebrew installation is Homebrew-owned: upgrade it with `brew upgrade --cask pz-base`, and stop
the agents with `pz-base service uninstall` before removing it. It does not self-update, which is
the same rule the `.deb` and `.rpm` packages follow.

Apple Silicon only. There is no Intel build.

## Do not edit the casks by hand

`Casks/pz-base.rb` is written by the `pz-base` release pipeline. The version and the digest come
from the release checksum manifest after its signature has been verified, so a hand edit here
breaks the only chain of custody the cask has.
