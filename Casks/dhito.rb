cask "dhito" do
  version "0.4.23"
  sha256 "7ee95bc161e03a6b7d2ac54c8f8a9493e96dc514676f250ad341f44c464c96c7"

  # The DMG asset name is not versioned, but the release tag in the path is, so
  # each version resolves to its own immutable URL. Do not switch this to the
  # /releases/latest/download/ alias: its contents change under a fixed URL, and
  # the sha256 above could then never match for more than one release.
  url "https://github.com/manzitwaal/ml-release/releases/download/v#{version}/dhito-production.dmg",
      verified: "github.com/manzitwaal/ml-release/"
  name "Dhito"
  desc "On-device semantic search for local documents, images, audio, and video"
  homepage "https://dhito.io/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Dhito ships a Tauri updater and updates itself in place. Declaring that here
  # stops Homebrew from treating a self-updated bundle as a corrupted install.
  auto_updates true

  # Verified against the 0.4.22 DMG: Contents/MacOS/dhito is arm64-only, as are
  # the bundled ffmpeg and ffprobe. An arm64-only binary cannot run under
  # Rosetta, so on an Intel Mac this would install cleanly and then fail to
  # launch. Fail at install time with a clear message instead.
  depends_on arch: :arm64
  depends_on macos: :ventura

  app "dhito.app"

  # The index, models, and logs live outside the bundle and survive an ordinary
  # uninstall — deliberately, so reinstalling does not force a multi-hour
  # re-index. `brew uninstall --zap` is the way to reclaim that disk space.
  zap trash: [
    "~/Library/Application Support/com.dhito.app",
    "~/Library/Caches/com.dhito.dhito",
    "~/Library/Preferences/com.dhito.dhito.plist",
    "~/Library/Saved Application State/com.dhito.dhito.savedState",
    "~/Library/WebKit/com.dhito.dhito",
  ]
end
