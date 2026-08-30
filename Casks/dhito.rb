cask "dhito" do
  version "0.4.29"
  sha256 "26bba26c41438f2268cca71965eb54a09863b8efd7205ccbae61a77290dbbb62"

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

  # What lands on disk, and what does not. Worth stating explicitly because the
  # DMG is not the whole story: the chat model is fetched on first use, so disk
  # use roughly doubles the first time someone opens Chat with Files. The sed in
  # the release workflow only rewrites the version and sha256 lines above, so
  # this text survives an automated cask bump.
  caveats <<~EOS
    Dhito runs entirely on your Mac. The search models ship inside the app:
    Whisper (speech), Florence-2 (vision and OCR), BGE-small-en-v1.5
    (embeddings) and an MS-MARCO cross-encoder (reranking). Bundled ffmpeg and
    ffprobe handle media decoding. That is about 1.2 GB installed.

    The Qwen3 chat model is not bundled. It downloads on first use of Chat with
    Files, sized to your machine: ~1.3 GB on Macs with 12 GB RAM or less,
    ~2.5 GB on 16 GB and above. Search works without it.

    Your files are never uploaded, and no file contents, filenames or search
    queries are collected. The only outbound request is licence validation.

    Indexing runs locally, so the first pass over a large library can take
    hours. Files become searchable as each one finishes.

    Free for 14 days with no account and no card, then $4.99/month.
  EOS
end
