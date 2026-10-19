# LookInsideTweak

LookInsideTweak loads the LookInside debug server into the iOS apps you choose on a jailbroken device. You don't need to change or re-sign the app. Connect the device to your Mac over USB, open LookInside on the Mac, and inspect the app.

Website: [lookinside-app.com](https://lookinside-app.com)

## Requirements

- iOS 15 or later
- A rootless jailbreak (such as Dopamine) or a roothide jailbreak
- ElleKit or another injector that provides `mobilesubstrate`
- PreferenceLoader
- LookInside on your Mac

## Install

Add the OwnGoal Studio repository `https://apt.owngoal.dev/` in your preferred package manager and install **LookInsideTweak**; it picks the right package for your jailbreak.

Or download the package for your jailbreak from [Releases](https://github.com/LookInsideApp/LookInside-Tweak/releases/latest) and install it with your preferred package manager, or with `dpkg -i`.

| Jailbreak | Package                                              |
| --------- | ---------------------------------------------------- |
| Rootless  | `app.lookinside.tweak_<version>_iphoneos-arm64.deb`  |
| roothide  | `app.lookinside.tweak_<version>_iphoneos-arm64e.deb` |

Not sure which one? Run `dpkg --print-architecture` on the device. Check your download against `SHA256SUMS` on the release page.

## Use

1. Open **Settings → LookInside** and make sure **Enable LookInside** is on.
2. Tap **Choose Apps** and turn on the apps you want to inspect.
3. Quit those apps if they are running, then open them again. The change applies the next time an app launches.
4. Connect the device to your Mac with a USB cable and open LookInside on the Mac.

Settings follows the system language: English, Arabic, Chinese (Simplified and Traditional), French, German, Italian, Japanese, Korean, Portuguese (Brazil), Russian, Spanish and Vietnamese.

Apps that already include a Lookin or LookInside server are skipped. On roothide, apps on the RootHide Manager blacklist load no tweaks, so remove an app from the blacklist before you turn it on here. Up to five apps can connect to LookInside at the same time.

To stop loading LookInside Server in every app without uninstalling, turn off **Enable LookInside** in Settings, or create the file `/var/mobile/Library/app.lookinside.tweak/disabled` inside the jailbreak root (under `/var/jb` on rootless).

## Build from source

The build uses the Xcode toolchain, not Theos. You need Xcode, `ldid`, `dpkg` and `zstd`, and bash 4 or later for the scripts. The Settings pane links the private Preferences framework, which the Xcode SDK leaves out, so you also need `iPhoneOS16.5.sdk` from [theos/sdks](https://github.com/theos/sdks) at the commit pinned in `configuration/build.env`; the build checks that it is that exact SDK.

```sh
PREFS_SDK=/path/to/iPhoneOS16.5.sdk make debs
```

`make debs` writes both packages, their debug symbols and `SHA256SUMS` to `build/pkg/`. `make check` runs the static checks alone.

The packages carry LookInside Server from [LookInside-Release](https://github.com/LookInsideApp/LookInside-Release); `configuration/server.env` pins its version and sha256, and the build downloads it. To try a local build of the server instead, pass its path:

```sh
SERVER_XCFRAMEWORK=/path/to/LookInsideServer.xcframework PREFS_SDK=/path/to/iPhoneOS16.5.sdk make debs
```

## License

MIT. See [LICENSE](LICENSE).

## Sponsor

This project is sponsored by [AirBuild](https://air.build/).
