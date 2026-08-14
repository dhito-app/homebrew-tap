# Dhito Homebrew Tap

Install [Dhito](https://dhito.io) — private, on-device semantic file search for macOS — with Homebrew.

```sh
brew tap dhito-app/tap
brew install --cask dhito
```

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

```sh
VERSION=0.4.22
curl -sL -o /tmp/dhito.dmg \
  "https://github.com/manzitwaal/ml-release/releases/download/v${VERSION}/dhito-production.dmg"
shasum -a 256 /tmp/dhito.dmg
# then edit version + sha256 in Casks/dhito.rb and push
```

Verify a change before pushing it:

```sh
brew audit --cask --online Casks/dhito.rb
brew install --cask Casks/dhito.rb
```
