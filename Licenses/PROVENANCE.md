# Provenance

Everything this repository ships is MIT, BSD, Apache-2.0, ISC or zlib. LGPL/GPL
code or text is never copied in; a GPL hooking runtime may appear only as a
`Depends`. External build inputs (the Xcode and Theos SDKs) are recorded in
`configuration/build.env` and are never committed or shipped.

Third-party notices travel with the binary at
`<prefix>/usr/share/doc/<package-id>/NOTICE` (empty prefix on roothide,
`/var/jb` on rootless); the `NOTICE` source is `Licenses/NOTICE`.

## Borrowed headers and stubs

| item | upstream | commit | license | what was copied |
| --- | --- | --- | --- | --- |
| `stubs/roothide/roothide.h` | RootHide/libroothide (`owngoal-dev/libroothide` mirror) | `7764c54759009272b4f2f23c18c62b21794fe6dd` | MIT | the public header only, unchanged; upstream LICENSE carried as `stubs/roothide/LICENSE` (the header has no per-file notice) |

## Prebuilt components

| item | upstream | pin | license | how it ships |
| --- | --- | --- | --- | --- |
| `LookInsideServer.framework` | LookInsideApp/LookInside-Server, published as `LookInsideServer.xcframework.zip` in LookInsideApp/LookInside-Release | the version and sha256 in `configuration/server.env`; `scripts/fetch-server.sh` refuses any other bytes | MIT | the iOS device slice (arm64 + arm64e) and its `Info.plist`, at `<prefix>/Library/Frameworks/LookInsideServer.framework`; the build changes only its install name, then strips and re-signs it ad hoc |

## Own stubs

| item | how it was written |
| --- | --- |
| `stubs/libroothide.tbd` | hand-written text-based-dylib stub. `install-name @loader_path/.jbroot/usr/lib/libroothide.dylib`, `arm64`/`arm64e`. Exports were dumped from a compile of `stubs/roothide/roothide.h` with `nm -u` (the C, ObjC and C++ overloads of `jbroot`/`rootfs` plus `jbrand` and the `*_alloc` forms) — see `scripts/verify-symbols.sh` and the CI diff against the header. No Theos vendor tbd was copied. |

## SDKs (external inputs, never committed or shipped)

| SDK | reported version | digest method | recorded in |
| --- | --- | --- | --- |
| Theos `iPhoneOS16.5.sdk` (from `theos/sdks`, as `PREFS_SDK` for the Settings pane's Preferences framework) | 16.4 | git tree id `81466d46b666daa04ae3d2b0b9d5324f0f621359` | `configuration/build.env` |
