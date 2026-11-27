# AngolMag (web)

Web version of **AngolMag**, the English vocabulary SRS app (Flutter, FSRS scheduling, Hive storage).

Live: https://guywitharicecooker.github.io/angolmag/

- Source: the Flutter app (`lib/`, `pubspec.yaml`), same UI as the Android app.
- Web-only tweaks: the Android TTS engine is skipped in the browser, the dictionary is written to storage in one batch, and the page title / manifest say "AngolMag".
- Binary web icons are stored as base64 (`*.png.b64`) and restored at build time.
- `.github/workflows/deploy.yml` builds with Flutter 3.19.6 (`flutter build web --release --base-href /angolmag/`) and publishes `build/web` to the `gh-pages` branch, which GitHub Pages serves.
