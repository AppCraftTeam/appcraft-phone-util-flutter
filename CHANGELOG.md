# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1]

### Fixed

- Dangling library doc comment in
  `lib/src/presentation/ac_phone_presentation.dart` causing pub.dev
  static analysis penalty (analyzer info `dangling_library_doc_comments`).
  Resolved by adding an unnamed `library;` directive after the
  doc-comment block.
- `CHANGELOG.md` non-ASCII content causing the pub.dev
  «Provide a valid CHANGELOG.md» score to drop to 0/5. All historical
  entries translated to English (ASCII-only).

### Changed

- `CHANGELOG.md` fully translated to English. Dates removed from
  version headings: format is now `## [X.Y.Z]` instead of
  `## [X.Y.Z] - YYYY-MM-DD`. Git log remains the source of truth
  for release dates.
- Minimum Dart SDK constraint bumped from `>=2.14.0` to `>=2.19.0`.
  Required by the unnamed `library;` directive used to attach the
  library-level doc comment in `ac_phone_presentation.dart`.

### Internal

- Added `.github/workflows/publish.yml` for automated publishing
  to pub.dev on git tag `v*` push. Uses OIDC authentication via the
  reusable `dart-lang/setup-dart/.github/workflows/publish.yml@v1`
  workflow; no long-lived `PUB_TOKEN` secret required. Pre-publish
  steps run `dart analyze --fatal-infos --fatal-warnings` and
  `flutter test`; the version in `pubspec.yaml` is verified to match
  the pushed tag.
- Added regression test `test/changelog_ascii_test.dart` enforcing
  non-ASCII ratio < 5% in `CHANGELOG.md`. Prevents future
  reintroduction of non-English content into the changelog.

## [1.2.0]

### Added

- Exported `ACPhoneCountries` class from `ac_phone_util.dart` —
  public access to the supported countries registry
  (`ACPhoneCountries.instance.all`, `.instance.hashedCountries`).
  Previously the class was only accessible through `lib/src/`.

### Fixed

- Analyzer info `include_file_not_found` for
  `package:flutter_lints/flutter.yaml` in `example/`: added
  `flutter_lints: ^3.0.0` to `dev_dependencies` of
  `example/pubspec.yaml`.
- `dart pub publish --dry-run` warning «checked-in files are ignored
  by a .gitignore»:
  - `pubspec.lock` removed from git index (library convention —
    lockfile is not committed);
  - `.vscode/` removed from `.gitignore` (launch.json is committed
    for the team), excluded from the published package via the
    new `.pubignore`.
- Lint `implementation_imports` in
  `example/lib/national_phone_demo_page.dart`: import switched to
  the public entry-point after `ACPhoneCountries` was exported.

### Notes

- Existing imports
  `import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';`
  continue to work.
- Library runtime behavior is unchanged — only the public API is
  extended and the dev environment + publish pipeline are fixed.

## [1.1.1]

### Added

- `LICENSE` file (MIT) at the package root — required for
  publication on pub.dev.
- `lib/appcraft_phone_util_flutter.dart` — canonical entry-point
  matching the package name. Equivalent to the existing
  `lib/ac_phone_util.dart` (re-export).

### Changed

- `pubspec.yaml`: added `repository`, `homepage`, `issue_tracker`,
  `topics` fields.
- `pubspec.yaml`: `description` expanded — accurately reflects the
  package functionality (parsing, validation, formatting, country
  detection, input masking).
- `README.md`: installation via `flutter pub add` is now the primary
  instruction; the git source is kept as secondary `## From source`.

### Notes

- Existing imports
  `import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';`
  continue to work without changes — backward compatibility is
  guaranteed by the smoke test `canonical_entry_point_test.dart`.
- Runtime behavior is unchanged — only metadata and the publish
  artifact structure. First publication on pub.dev.

## [1.1.0]

### Added

- Public contract for `ACPhoneInputFormatter`: explicit digits-only
  filtering guarantee — non-digit characters (letters, emoji,
  punctuation, unicode whitespace) are dropped on input and paste.
  `FilteringTextInputFormatter.digitsOnly` is no longer required
  alongside `ACPhoneInputFormatter`.

### Changed

- `ACPhoneEditingController`: when `text` changes, automatically
  replaces the trunk-prefix digits with the digits of the actual
  `phoneCode` of the detected country. For example, entering
  `89008007060` without a formatter produces `text = '79008007060'`
  (country = RU); with
  `ACPhoneInputFormatter(mask: '+# (###) ###-##-##')` —
  `+7 (900) 800-70-60`. The replacement is surgical: it touches
  only the first N digit characters (N = length of the digits
  version of `phoneCode`), preserves the mask/separators and the
  cursor position by digit-count. For numbers where the
  trunk-prefix already matches `phoneCode` (`+79...`, `+380...`),
  the rewrite is not invoked. Masking remains entirely the
  responsibility of the formatter.
- `example/lib/national_phone_demo_page.dart`: removed redundant
  `FilteringTextInputFormatter.digitsOnly` from `inputFormatters` —
  demonstrates simplified integration.

### Fixed

- `ACPhoneInputFormatter`: backspace on a mask separator (`(`, `)`,
  `-`, space) now removes the preceding digit — fixes editing
  stalls on formatted numbers.
- `ACPhoneEditingController`: automatic removal of a lone `+` when
  the last digit of the number is erased.
- `ACPhoneInputFormatter`: trimming of trailing separators after
  the last digit — eliminates stalls when deleting (+7, +7 (900)
  and similar partial states).

### Refactored

- `ACPhoneEditingController`: `_isRewriting` replaced with
  `_lastText` — memo-guard plus saving on `findPhone` when only
  the selection changes.

## [1.0.0]

### BREAKING CHANGES

- `ACPhoneInputFormatter`: parameters `country` and
  `onPhoneChanged` removed. The formatter now takes a single
  required parameter `mask: String`. Auto-detection of the country
  is no longer built into the formatter — use
  `ACPhoneEditingController` (auto-detect) or
  `ACNationalPhoneEditingController` (with an explicit country).
- `ACPhoneCountry.telMask` renamed to `nationalMask`. Behavior
  changed: parentheses and dashes are now preserved. For the old
  behavior (without parentheses and dashes) use the new
  `rawNationalMask`.

### Added

- `ACPhoneCountry.rawMask` — full mask without `(`, `)`, `-`;
  separator is space only.
- `ACPhoneCountry.rawNationalMask` — national mask without `(`,
  `)`, `-`.
- `ACNationalPhoneEditingController` — input controller for the
  national part of the number with an externally provided country
  (`country` via constructor and setter). `rawPhoneNumber` returns
  the full number, `isValid` validates via `ACPhoneUtil`.
- Example application updated: two separate demo pages
  (`auto_detect_demo_page.dart`, `national_phone_demo_page.dart`)
  with navigation from the home screen.

### Migration

```dart
// BEFORE (0.0.1)
ACPhoneInputFormatter(country: country, onPhoneChanged: (d) => ...);

// AFTER (1.0.0) — full number
ACPhoneInputFormatter(mask: country.mask);

// AFTER — national part only
ACPhoneInputFormatter(mask: country.nationalMask);
```

## [0.0.1]

### Added

- Phone number parsing and validation (`ACPhoneUtil`)
- Country detection by phone code with 200+ countries
- Localized country names in 36 languages (`ACPhoneCountryLocalizations`)
- Phone number input formatter (`ACPhoneInputFormatter`) with auto-detection and fixed mask modes
- Phone editing controller (`ACPhoneEditingController`) with phone data access and validation
- Example application demonstrating library usage
