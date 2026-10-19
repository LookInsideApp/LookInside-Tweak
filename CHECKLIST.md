# LookInsideTweak — Checklist

One time, before the first release. `make check` runs `scripts/check-checklist.sh`
first, and every build target depends on it, so nothing builds until every box
below is ticked. Tick a box only after doing or deciding the thing, never to get
past the gate; tick an item that does not apply with the reason written after it.
Where an item is evidence-backed, name the verifiable artifact beside the box.

## Identity and rename

- [x] `configuration/build.env` is filled (TWEAK_NAME, PACKAGE_ID, MIN_IOS, SDK settings) and the placeholder sweep is empty: `grep -rnE '@[A-Z][A-Z0-9_]*@' --exclude-dir=.git .` shows only the packager tokens.
      `configuration/build.env`, `configuration/server.env`.
- [x] No file names a product other than LookInside, LookInside Server and the jailbreak and injector products.
      `make check`.
- [x] There is no `CLAUDE.md` or `AGENTS.md` in this public repository, and no file names a package manager.
      `scripts/check-layout.sh`, `scripts/check-docs.sh`.

## Hook targets and filter

- [x] N/A: nothing is hooked. The filter names `com.apple.UIKit` because the user picks the apps at run time; the constructor returns at once in any app the user did not turn on.
      `src/tweak.m`, `packaging/TWEAK.plist`.
- [x] The constructor's first check is the identity guard (the app's bundle identifier against the apps turned on in Settings), and the kill-switch marker path is documented in the release notes.
      `src/tweak.m`, `packaging/release-notes.md`.

## Substrate provider

- [x] `mobilesubstrate` is the only provider in `configuration/depends.env`; MSHook* is not used at all.
      `configuration/depends.env`.

## Scheme paths

- [x] Every bootstrap-relative path goes through `TW_JBROOT`; the literal `/var/jb` appears only in `src/tw_jbpath.h`; the settings and the kill-switch marker live under `TW_JBROOT("/var/mobile/Library/app.lookinside.tweak/")`.
      `src/tw_settings.h`, `src/tweak.m`.

## arm64e proof

- [x] Both flavors build and `verify-payload.sh` passes. Both are fat arm64 + arm64e: App Store apps run as arm64 processes and system apps as arm64e, and both must load the tweak and LookInside Server. The roothide slices link only our own `stubs/libroothide.tbd`; the rootless slices link no libroothide.
      `make debs`.

## Preference bundle

- [x] `src/prefs/` ships. `PREFS_SDK` is the pinned Theos `iPhoneOS16.5.sdk` (Release fetches it), the bundle builds as MH_BUNDLE against our own Preferences declarations in `src/prefs/LITPreferences.h`, and `preferenceloader` is in Depends.
      `scripts/build-ios.sh`, `scripts/verify-payload.sh`.

## Helper / daemon trust

- [x] N/A: no helper ships.

## Prebuilt LookInside Server

- [x] LookInside Server comes from a published LookInside-Release XCFramework pinned by version and sha256 in `configuration/server.env`; it is the only prebuilt Mach-O, the payload gate allows only its framework path, and its one import-denylist exception (`_socket`, to listen for the Mac) is recorded there.
      `scripts/fetch-server.sh`, `scripts/verify-payload.sh`, `scripts/verify-symbols.sh`.

## postinst restart

- [x] The maintainer scripts restart nothing (the target apps load the Server at their next launch), no daemon ships, and `purge` deletes only the state dir and the preference plist.
      `packaging/DEBIAN/`.

## Licenses

- [x] `Licenses/PROVENANCE.md` and `Licenses/NOTICE` are accurate; LookInside Server and `roothide.h` are MIT; no GPL/LGPL text is copied in; `LICENSE` names LookInsideApp contributors, 2026.
      `Licenses/`.

## Release

- [x] The tag, workflow names, pinned SHAs and draft-then-public flow are in place; nothing built locally is ever uploaded; the sensitive-information read-through is a step of every push, tag and release.
      `.github/workflows/`.
