# Dhito Homebrew Tap

Install [Dhito](https://dhito.io) — private, on-device semantic file search for macOS — with Homebrew.

```sh
brew tap dhito-app/tap
brew trust --cask dhito-app/tap/dhito
brew install --cask dhito
```

Homebrew 6.0 and later refuse to load a cask from a third-party tap until you
explicitly trust it, so the middle command is required — without it, `brew
install` stops with "Refusing to load cask … from untrusted tap". On older
Homebrew versions `brew trust` does not exist; skip that line, the other two
work unchanged.

To update:

```sh
brew upgrade --cask dhito
```

To uninstall, including the local search index and all app data:

```sh
brew uninstall --cask dhito
brew uninstall --zap --cask dhito   # also removes ~/Library/Application Support/com.dhito.app
```

## Why this tap exists rather than the main homebrew-cask repo

Homebrew's official cask repository applies a notability bar to software from
independent vendors — roughly, an established audience or a GitHub project with
a meaningful star/fork count. Dhito does not clear it yet, so a PR to
homebrew-cask would be closed on those grounds regardless of the cask's quality.

A self-hosted tap needs nobody's approval and gives users the same
`brew install` / `brew upgrade` workflow today. Once Dhito clears the notability
bar, the cask in `Casks/dhito.rb` can be submitted upstream essentially as-is,
and this tap kept as a redirect so nobody's existing install breaks.

## What the cask installs

`Casks/dhito.rb` points at the signed, Apple-notarized DMG published on each
tagged release of the private build pipeline. Homebrew verifies the SHA256
before installing, so a tampered or truncated download fails loudly.

The app ships its own Tauri-based updater, which is why the cask sets
`auto_updates true`: Homebrew records the install but leaves version updates to
the app, so the two never fight over the same bundle.

## Releasing a new version

The cask must be bumped whenever a new app version ships, or `brew install`
keeps handing users an old build. The `Bump Homebrew cask` step in the app
repo's `.github/workflows/release.yml` does this automatically on every tag —
see that file for the required `HOMEBREW_TAP_TOKEN` secret.

To bump by hand:

Read the version from the latest release rather than typing one in, so this
snippet cannot go stale the way a pinned number does:

```sh
VERSION=$(gh release view --repo manzitwaal/ml-release --json tagName -q .tagName | sed 's/^v//')
curl -sL -o /tmp/dhito.dmg \
  "https://github.com/manzitwaal/ml-release/releases/download/v${VERSION}/dhito-production.dmg"
shasum -a 256 /tmp/dhito.dmg
# then edit version + sha256 in Casks/dhito.rb and push
```

Verify a change before pushing it. Note that Homebrew rejects cask *file paths*
outright — "Homebrew requires casks to be in a tap" — so `audit` and `install`
have to address the cask by token, and only `style` accepts a path:

```sh
brew style Casks/dhito.rb              # lints the working copy, path is fine here
brew audit --cask --online dhito-app/tap/dhito
brew install --cask dhito-app/tap/dhito
```

`audit` and `install` read the tap Homebrew has cloned under
`$(brew --repository)/Library/Taps/dhito-app/homebrew-tap`, not this checkout,
and that clone only refreshes on `brew update`. So they validate what is
*published*, not what you are about to push — run `brew style` on the file for
the latter. To exercise unpushed changes end to end, point a tap at this
directory instead:

```sh
brew untap dhito-app/tap
brew tap dhito-app/tap "file://$(pwd)"
```
