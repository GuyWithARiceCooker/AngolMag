# AngolMag (web)

Web version of **AngolMag**, the English vocabulary SRS app (Flutter, FSRS scheduling, Hive storage).

Live: https://guywitharicecooker.github.io/AngolMag/ (Pages paths are case-sensitive, so the base href must be /AngolMag/)

- Source: the Flutter app (`lib/`, `pubspec.yaml`), same UI as the Android app.
- Web-only tweaks: the Android TTS engine is skipped in the browser, the dictionary is written to storage in one batch, and the page title / manifest say "AngolMag".
- Binary web icons are stored as base64 (`*.png.b64`) and restored at build time. They are an original geometric "A" mark on the app's amber colour (they replace the default Flutter logo, which the Flutter brand guidelines do not allow as an app icon).
- `.github/workflows/deploy.yml` builds with Flutter 3.19.6 (`flutter build web --release --base-href /AngolMag/`) and publishes `build/web` to the `gh-pages` branch, which GitHub Pages serves.

## Credits and licences

Third-party licences, Font Awesome attribution, and a note on the word-list data are in [NOTICE.md](NOTICE.md). This repository does not yet include a project `LICENSE` for the original AngolMag source.
