# HexaGlow App

Flutter control UI for the HexaGlow LED hexagon piece. Targets Windows
desktop and Android, communicating with the ESP32 over UDP on port 4210
using the same plain-text commands the firmware's `EventHandler` parses
(`COLORALL`, `COLORHEX`, `COLOREDGE`, `COLORPIXEL`, `BRIGHTNESS`, `CLEAR`).

## First-time setup

The `lib/`, `test/`, and `pubspec.yaml` in this directory were hand-written
before `flutter create` was run, so the platform folders (`android/`,
`windows/`, etc.) don't exist yet. Generate them in place:

1. Install the Flutter SDK and run `flutter doctor`. Make sure Windows
   desktop and Android toolchains show as ready (enable Windows desktop
   with `flutter config --enable-windows-desktop` if needed).
2. From this directory (`app/hexaglow_app`), run:

   ```
   flutter create --platforms=windows,android --org com.hexaglow .
   ```

   This adds the missing `android/`, `windows/`, and other scaffold files.
   It should not overwrite the existing `pubspec.yaml` or `lib/` since they
   already exist - afterwards run `git status`/`git diff` to confirm nothing
   unexpected changed (e.g. `pubspec.yaml`'s `name:` field should still read
   `hexaglow_app`).
3. Install dependencies:

   ```
   flutter pub get
   ```

4. Verify:

   ```
   flutter analyze
   flutter test
   ```

5. Run on Windows:

   ```
   flutter run -d windows
   ```

   Run on an Android device/emulator:

   ```
   flutter run -d <device-id>
   ```

   On Android, confirm `android/app/src/main/AndroidManifest.xml` contains
   `<uses-permission android:name="android.permission.INTERNET" />` (UDP
   sockets require it; `flutter create` includes it by default).

## Using the app

1. Open Settings (gear icon) and enter your ESP32's IP address (the port
   defaults to 4210, matching `Connection::localPort` in the firmware).
2. On the home screen, tap the lock icon to enter "Edit layout" mode and
   drag the 7 hexagons to mirror your physical arrangement. The layout is
   saved automatically.
3. Tap a hexagon (outside edit mode) to open its detail screen, where you
   can set its whole color or each of its 6 edges individually via a color
   wheel.
4. Use "Color All", the brightness slider, and "Clear" at the bottom of the
   home screen for global commands.

## Notes

- Edge numbering (0-5) is a UI convention matching the order
  `hexagonCorners()` produces in `lib/utils/hex_geometry.dart`; it doesn't
  necessarily correspond to a specific physical direction unless you verify
  it against your wiring.
- Colors shown in the UI are optimistic (last command sent from this app) -
  the firmware has no state read-back, so the UI resets to black on
  restart.
- The companion firmware change adding `COLORHEX hex_index r g b` lives in
  `src/EventHandler.cpp` at the repo root.
