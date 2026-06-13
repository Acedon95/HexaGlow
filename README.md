# HexaGlow

HexaGlow is a physical LED art piece made of **7 hexagons**, each ringed by
**18 WS2812B LEDs** (126 LEDs total), wired as one shared NeoPixel strip and
driven by an **ESP32**. The ESP32 connects to your WiFi and listens for
simple UDP text commands, which it translates into LED colors.

A companion **Flutter app** (Windows desktop + Android) provides a visual,
drag-to-arrange control surface: arrange the 7 hexagons to match your
physical layout, then tap edges/hexagons to pick colors, adjust brightness,
save/load presets, and clear the whole piece.

```
HexaGlow/
├── src/, include/, lib/, test/   ESP32 firmware (PlatformIO project)
├── data/                         SPIFFS filesystem image (WiFi credentials)
├── platformio.ini                Firmware build configuration
├── app/hexaglow_app/             Flutter app (Windows + Android)
└── hexagon_ring_outer100mm_*.stl 3D-printable hexagon ring (100mm, for 18 LEDs)
```

---

## 1. Firmware (ESP32)

The firmware is a [PlatformIO](https://platformio.org/) project rooted at
the repo root (`platformio.ini`, `src/`, `include/`).

### 1.1 Hardware setup

- **Board**: ESP32 dev kit (configured as `fm-devkit` in `platformio.ini`)
- **Data pin**: GPIO 4 (`LED_PIN` in [src/main.cpp](src/main.cpp))
- **LED count**: 126 (7 hexagons × 18 LEDs), type WS2812B (`NEO_GRB + NEO_KHZ800`)

NeoPixel best practices (see comments at the top of
[src/main.cpp](src/main.cpp)):
- Add a ~1000 µF capacitor across the strip's + and - rails.
- Keep the wire between the ESP32 and the first pixel short.
- Put a 300–500 Ω resistor on the data line.
- Always connect ground first when wiring live.
- A 3.3V → 5V logic-level converter on the data line is recommended.

### 1.2 WiFi configuration

The ESP32 connects to your WiFi as a client. Credentials are **not**
hardcoded — they're read at boot from a small config file stored in the
ESP32's SPIFFS filesystem.

1. Copy the example file and fill in your network details:
   ```
   data/.config.example  →  data/.config
   ```
   `data/.config` looks like:
   ```
   ssid:<your-ssid>
   password:<your-pw>
   ```
2. `data/.config` is **gitignored** (it contains real credentials) — make
   sure it exists locally before you upload the filesystem image.
3. Upload the filesystem image to the ESP32 (separately from the firmware):
   ```sh
   pio run --target uploadfs
   ```

You only need to redo step 3 when your WiFi credentials change.

### 1.3 Building and flashing the firmware

From the repo root (with the ESP32 connected via USB):

```sh
# Compile only (no hardware needed, useful to check for errors)
pio run

# Compile and flash to the connected ESP32
pio run --target upload

# Open a serial monitor at 115200 baud (boot logs, IP address, etc.)
pio device monitor
```

On boot, the ESP32:
1. Mounts SPIFFS and connects to WiFi using `data/.config`.
2. Prints its assigned IP address over serial (115200 baud) — **you need
   this IP address for the app's Settings screen**.
3. Plays a green "boot" animation, lighting up each hexagon in turn.
4. Starts listening for UDP commands on port **4210**.

> **Tip:** Your router may assign the ESP32 a different IP address after a
> power cycle unless you set up a DHCP reservation / static IP for it. If
> the app stops responding after a restart, check the serial monitor for the
> current IP and update it in the app's Settings screen.

### 1.4 UDP protocol reference

All commands are plain ASCII text, space-separated, sent as a single UDP
datagram to the ESP32's IP on port **4210**. This is the protocol the
Flutter app speaks; you can also test it manually with `nc -u <esp32-ip> 4210`.

| Command | Format | Description |
|---|---|---|
| Clear | `CLEAR` | Turns off all LEDs on all 7 hexagons. |
| Color all | `COLORALL r g b` | Sets every LED on the whole strip to one color. |
| Color hexagon | `COLORHEX hex_index r g b` | Sets every LED of one hexagon to one color. |
| Color edge | `COLOREDGE hex_index edge r g b` | Sets the 3 LEDs of one edge of one hexagon. |
| Color pixel | `COLORPIXEL hex_index index r g b` | Sets a single LED. |
| Brightness | `BRIGHTNESS value` | Sets global strip brightness (0-255). |

- `hex_index` is **1-7** (1-based, matches the numbers shown in the app).
- `edge` is **0-5** — one of the 6 edges of a hexagon (3 LEDs each).
- `index` (for `COLORPIXEL`) is the **absolute** LED index 0-125 across the
  whole strip.
- `r`, `g`, `b` are **0-255**.

---

## 2. Flutter App

Location: **`app/hexaglow_app/`**

A single Flutter codebase that builds for **Windows desktop** and
**Android**. It talks to the ESP32 over UDP using the protocol above.

### 2.1 What the app does

- **Home screen** — a freely-arrangeable canvas showing all 7 hexagons.
  - **Edit layout** (lock/unlock icon, top right): drag hexagons around to
    match your physical arrangement; the layout is saved automatically.
    While editing, each hexagon shows a rotate button that performs the
    **visual** 30° rotation of its on-screen graphic (purely cosmetic, to
    match how the hexagon is physically oriented).
  - **Color All**: opens a color wheel and sets every edge LED on every
    hexagon to the chosen color.
  - **Clear**: turns everything off (`CLEAR`).
  - **Brightness slider**: sets global strip brightness (sent once you
    release the slider).
- **Hexagon detail screen** (tap a hexagon): per-hexagon controls.
  - **Set whole hexagon color**: colors every LED of that hexagon.
  - **Edge list (Edge 0-5)**: tap an edge to pick its color individually.
  - **Rotate edges**: performs the **logical** 60° edge remap — use this if
    a hexagon's physical wiring is rotated relative to the others, so "Edge
    0" in the app always corresponds to the same physical edge across all
    hexagons, regardless of rotation.
  - **Individual pixels (advanced)**: a 3×6 grid for per-LED colors.
- **Color Presets screen** (palette icon): save the current full-piece
  color state (all hexagons + brightness) under a name, then reload or
  delete saved presets later.
- **Settings screen** (gear icon): set the ESP32's **IP address** and **UDP
  port** (default `192.168.1.100:4210`). This must match the IP printed by
  the ESP32 over serial (see [1.3](#13-building-and-flashing-the-firmware)).

All color/layout/preset/settings state is persisted locally on the device
(via `shared_preferences`). The LEDs themselves have no memory — if the
ESP32 reboots, it comes back to its boot animation and "off" state, and the
app's saved colors are just its best guess of what's currently showing until
you send a new command.

### 2.2 First-time setup

1. Flash and power on the ESP32 (see section 1) and note its IP address from
   the serial monitor.
2. Open the app → **Settings** → enter that IP address (and port `4210` if
   unchanged) → **Save**.
3. Go back to the home screen and try **Color All** or **Clear** to confirm
   the app and ESP32 can talk to each other.
4. Use **Edit layout** to drag the 7 hexagons into the same arrangement as
   your physical piece, and use the per-hexagon **Rotate edges** control if
   any hexagon's wiring is rotated relative to the others.

### 2.3 Where to find the app files

#### Windows

Build (debug or release) from `app/hexaglow_app/`:
```sh
flutter build windows --debug    # or --release
```
The executable is produced at:
```
app/hexaglow_app/build/windows/x64/runner/Debug/hexaglow_app.exe     (debug)
app/hexaglow_app/build/windows/x64/runner/Release/hexaglow_app.exe   (release)
```
Run it directly, or create a desktop/taskbar shortcut to it — the shortcut
will use HexaGlow's hexagon icon automatically.

#### Android

Build a release APK from `app/hexaglow_app/`:
```sh
flutter build apk --release
```
The APK is produced at:
```
app/hexaglow_app/build/app/outputs/flutter-apk/app-release.apk
```
Copy this file to your Android phone (USB, cloud storage, email, etc.) and
install it — you'll need to allow "install from unknown sources" since it's
not distributed via the Play Store.

### 2.4 Development

From `app/hexaglow_app/`:
```sh
flutter pub get      # install dependencies
flutter analyze       # static analysis
flutter test          # run unit tests (models, providers, UDP command formatting)
flutter run -d windows  # run with hot reload on Windows
```

App icons (Windows `.ico` + Android `mipmap-*`) and the app background are
generated/sourced from `app/hexaglow_app/assets/`:
- `hexaglow_app_symbol.png` — app icon (regenerate with
  `dart run flutter_launcher_icons` after replacing it)
- `hexaglow_background_asset.png` — app-wide background image

---

## 3. Misc

- `hexagon_ring_outer100mm_wall5mm_height10mm.stl` — 3D-printable ring that
  holds 18 LEDs per hexagon (100mm outer diameter, 5mm wall, 10mm height).
- `src/gui.py` — an older standalone Python/PyQt UDP test GUI, superseded by
  the Flutter app. Requires `PyQt6`; edit `ESP32_IP`/`ESP32_PORT` at the top
  before use.
