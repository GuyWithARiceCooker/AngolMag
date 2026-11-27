# Notices for AngolMag

This file records third-party material used in the AngolMag source and in the web build.

## Origin of the app

AngolMag is the public name of a Flutter project that was developed locally under the package name `hive_again` (the default Flutter starter README, dated 28 May 2024 in the original tree). No separate upstream repository, licence file, or third-party author was found in the source tree, `pubspec.yaml`, git history, or a public web search (no other copies of `enhuDictionary.dart` showed up under the name hive_again). Redistribution and public hosting of this app are therefore a matter for the owner of this repository. This repository currently has no project `LICENSE` file, so the original source is not offered under an open-source licence unless one is added later.

## Fonts and icons bundled by Flutter

- Roboto and the Material Icons shipped by the Flutter SDK (`uses-material-design: true` in `pubspec.yaml`) are licensed under the Apache License 2.0. Redistribution and public hosting are allowed. Attribution is provided by the Apache licence text that Flutter embeds in a web release as `assets/NOTICES`.
- Those licences are permissive and are fine for this use.

## Font Awesome Free (via font_awesome_flutter)

The app uses free Font Awesome icons (the dumbbell, rotate, rating faces, and letter buttons) through the `font_awesome_flutter` package.

- Icons: Creative Commons Attribution 4.0 (CC BY 4.0)
- Fonts: SIL Open Font License 1.1
- Package code: MIT (Copyright (c) 2017 Brian Egan, 2020 Michael Spiss; Font Awesome Icons by @fontawesome — https://fontawesome.com)
- Font Awesome Free licence: https://fontawesome.com/license/free

Font Awesome's licence says downloaded files already contain sufficient attribution and that no further action is normally required, provided those notices are not stripped. This NOTICE, and Flutter's generated `assets/NOTICES` in the web build, keep that attribution.

## Direct Dart/Flutter dependencies

Licences below are as published on pub.dev for the versions locked in `pubspec.lock`. Transitive SDK and plugin licences are included in the Flutter web build's `assets/NOTICES` file. No GPL, AGPL, SSPL, Commons Clause, or non-commercial licence was found among the locked packages.

- Flutter SDK (`flutter`, `flutter_web_plugins`, `sky_engine`) — BSD-style / Apache 2.0 notices as bundled by Flutter
- `hive`, `hive_flutter` — Apache License 2.0
- `font_awesome_flutter` — MIT, plus Font Awesome Free as above
- `fsrs` — MIT (Copyright (c) 2022 Open Spaced Repetition)
- `flutter_tts` — MIT
- `translator` — MIT (Copyright (c) 2021 Gabriel Pacheco). The package is an unofficial Google Translate client. It is listed as a dependency, but its import is commented out in the current app code.
- `url_launcher` and its platform implementations — BSD-3-Clause
- `flutter_persistent_value_notifier`, `flutter_reactive_value` — MIT-0
- `icons_launcher` — MIT (used to generate launcher icons; not a runtime part of the web UI)
- Other transitive packages in `pubspec.lock` (`http`, `path_provider`, `shared_preferences`, and so on) — MIT, BSD, or Apache 2.0

A scan of the Flutter-generated NOTICES file found mentions of "non-commercial" only in the OpenSSL/SSLeay licence, which expressly allows commercial and non-commercial use, and mentions of GPL/AGPL only as defined "Secondary License" terms in an MPL-style notice, not as the licence of a dependency.

## Word list and dictionary data

`lib/english_words.dart` is a list of 49,948 English tokens, almost all lower-case. The conversational ranking (`you`, `i`, `the`, `yeah`, `okay`) plus subtitle-like artefacts (tokens ending in a hyphen such as `you-` and `um-`, doubled dashes such as `are--are`, and name-like tokens such as `hyeon-to` and `yeon-hee`) point to a list taken from spoken or subtitle text, not a hand-written glossary. The exact source file and licence were not identified in the repo, in comments, or in git history.

`lib/enhuDictionary.dart` maps those tokens to Hungarian glosses. Many glosses show machine-translation artefacts (for example `who` → `WHO`, `will` → `akarat`, `'re` → `'újra`, `at` → `nál nél`). The `translator` package is a dependency and was previously imported, which is consistent with a one-time generated translation table. No licence or source citation is present.

These word lists were not removed, because they are the core study data. Options for the owner:

1. If the English list came from a known research list such as SUBTLEX-US (Brysbaert & New), add the required academic attribution and keep it. Those authors have allowed reuse for any purpose with credit. This copy was not verified as a verbatim SUBTLEX extract (SUBTLEX would not normally include hyphen-cutoff tokens).
2. Replace the English list later with a clearly licensed frequency list (for example data from wordfreq, which is CC BY-SA 4.0 and requires attribution, or another list with a documented licence).
3. Replace or review the Hungarian glosses with a source that grants redistribution (a freely licensed bilingual dictionary, or original translations), rather than relying on an unofficial machine-translation API, whose terms of service may not allow storing and republishing translations at this scale.
4. Leave the data as-is for personal use, accepting that the provenance is undocumented.

Individual English words are generally not protected as copyrighted prose, but a substantial curated frequency list can be a protected compilation in some places, and published translations can be protected. Documenting or replacing the source is the conservative path.

## Audio

No audio files are bundled. Speech uses the device or browser text-to-speech engine through `flutter_tts` (on Android, Google TTS is requested). That is a runtime service, not a redistributed recording.

## Images and trademarks

- The web favicon and PWA icons in earlier commits were the default Flutter logo from `flutter create`. The Flutter brand guidelines do not allow the Flutter logo to be used as an app icon. Those files have been replaced with an original geometric "A" mark on the app's amber colour, drawn for this project. The replacement is at the same paths (`web/favicon.png`, `web/icons/Icon-192.png`, `web/icons/Icon-512.png`, and the maskable variants), stored as `*.png.b64` and restored at build time as before.
- A Union Flag / sprouting-seed launcher image (`assets/ic_logo_border.png`) exists in some local checkouts of the older Android/iOS tree. It is not in this GitHub `main` branch and is not used by the web app. Its authorship is undocumented (the PNG timestamp is 24 April 2024). It was not added here. National flags are generally fine to depict; if that image is later published, confirm it is original or permissively licensed, not a stock asset with a restricted licence.

## Outbound links (not bundled content)

The app opens the current word on third-party sites; it does not copy their content into the repository:

- https://hu.wiktionary.org/wiki/…
- https://hunglish.hu/search?…
- https://translate.google.com/…

Those names are used only to identify the services.

## Flutter-generated notices

A Flutter web release also writes a combined `assets/NOTICES` file into the build output. That file should be kept in the deployed site.
