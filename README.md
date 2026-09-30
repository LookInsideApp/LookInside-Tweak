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

Download the package that matches your jailbreak from the latest release:

| Jailbreak | Package |
| --- | --- |
| Rootless | `app.lookinside.tweak_<version>_iphoneos-arm64.deb` |
| roothide | `app.lookinside.tweak_<version>_iphoneos-arm64e.deb` |

Install it with your package manager or with `dpkg -i`, then respring.

## Use

1. Open **Settings → LookInside** and make sure **Enable LookInside** is on.
2. Tap **Choose Apps** and turn on the apps you want to inspect.
3. Quit those apps if they are running, then open them again. The change applies the next time an app launches.
4. Connect the device to your Mac with a USB cable and open LookInside on the Mac.

Settings appears in English or Simplified Chinese, following the system language.

Apps that already include a Lookin or LookInside server are skipped. On roothide, apps on the RootHide Manager blacklist load no tweaks, so remove an app from the blacklist before you turn it on here. Up to five apps can connect to LookInside at the same time.

## Build from source

You need [Theos](https://theos.dev) with rootless and roothide support (the [roothide Theos](https://github.com/roothide/theos) works) and `ldid`.

```sh
make server        # downloads LookInsideServer.xcframework from LookInside-Release
make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```

The packages are written to `packages/`.

To use a local build of the server, pass its path:

```sh
SERVER_XCFRAMEWORK=/path/to/LookInsideServer.xcframework make server
```

System apps such as SpringBoard and Settings run as arm64e and load the server only if it has an arm64e slice. Third-party apps load the arm64 slice.

## License

MIT. See [LICENSE](LICENSE).
