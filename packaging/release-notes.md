LookInsideTweak loads LookInside Server into the iOS apps you choose, so LookInside on your Mac can inspect them over USB. Built for jailbroken iOS as a MobileSubstrate tweak, for both roothide and rootless bootstraps, with LookInside Server @SERVER_VERSION@ inside.

## Which one do I download?

The architecture field names the **bootstrap layout, not the CPU**.

| your bootstrap | download |
| -------------- | -------- |
| roothide | `@PACKAGE_ID@_@VERSION@_iphoneos-arm64e.deb` |
| rootless | `@PACKAGE_ID@_@VERSION@_iphoneos-arm64.deb` |

Not sure? Ask the device: `dpkg --print-architecture`.

Requires **iOS @MIN_IOS@ or later**, an injector that provides `mobilesubstrate` (such as ElleKit), and PreferenceLoader.

## What gets injected and restarted

@INJECTION_SUMMARY@ The tweak loads LookInside Server only into the apps you turn on in **Settings → LookInside**, the next time each of them launches. Nothing is restarted on install; reopen Settings to see the LookInside page.

## Status

@STATUS_ROOTHIDE@
@STATUS_ROOTLESS@

## Uninstall and kill switch

Removing the package leaves your settings in place; choose **purge** in your preferred package manager to also delete this tweak's state and settings.

To stop loading LookInside Server everywhere without removing the package, turn off **Enable LookInside** in Settings, or create the marker file this tweak checks at launch (`@KILL_SWITCH_PATH@`); delete it to turn loading back on. Either change applies to apps launched afterwards. On roothide, per-app injection can also be turned off in the jailbreak's manager — if an app never shows up in LookInside, check that first.

## Verify your download

Check your download against `SHA256SUMS`.
