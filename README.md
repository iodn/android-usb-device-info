# USB Descriptor Explorer for Android

<a href="https://play.google.com/store/apps/details?id=org.kaijinlab.usbdevinfo">
<img src="fastlane/metadata/android/en-US/images/icon.png" width="160" alt="USB Descriptor Explorer icon" align="left" style="border: solid 1px #ddd;"/>
</a>
<div>
<h3 style="font-size: 2.2rem; letter-spacing: 1px;">USBDevInfo</h3>
<p style="font-size: 1.15rem; font-weight: 500;">
    <strong>USB Descriptor Explorer for Android</strong><br>
    <strong>USBDevInfo</strong> is an Android application for discovering, inspecting, and analyzing USB devices connected to your phone or tablet.  
It exposes the same low-level USB information that Android sees, but presents it in a clear, structured, and human-readable way.

The app is designed for developers, reverse-engineers, hardware hackers, and power users who need to understand exactly what a USB device reports: vendor IDs, configurations, interfaces, endpoints, HID descriptors, power requirements, and more.

USBDevInfo works fully offline, stores all data locally, and never transmits device information to any server.

  </p>

<div align="center">

  [![GitHub License](https://img.shields.io/github/license/iodn/android-usb-device-info)](LICENSE)
  [![Issues](https://img.shields.io/github/issues/iodn/android-usb-device-info.svg)](https://github.com/iodn/android-usb-device-info/issues)
  [![Pull Requests](https://img.shields.io/github/issues-pr/iodn/android-usb-device-info.svg)](https://github.com/iodn/android-usb-device-info/pulls)
  [![Android Version](https://img.shields.io/badge/Android-11.0%2B-green.svg)](https://www.android.com)
  
<div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
  <a href="https://f-droid.org/en/packages/org.kaijinlab.usbdevinfo/" style="display:inline-flex; align-items:center;">
    <img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
         alt="Get it on F-Droid"
         style="display:block; height:90px; width:auto;">
  </a>
  <a href="https://play.google.com/store/apps/details?id=org.kaijinlab.usbdevinfo" style="display:inline-flex; align-items:center;">
    <img src="https://raw.githubusercontent.com/pioug/google-play-badges/06ccd9252af1501613da2ca28eaffe31307a4e6d/svg/English.svg"
         alt="Get it on Google Play"
         style="display:block; height:70px; width:auto;">
  </a>
</div>
</div>

## Features
- Live USB monitoring
  - Automatically reacts to USB attach/detach and can auto‑open a device's details view on attach
  - Permission request flow for devices that require user consent
  - Instant visibility into attached USB devices, hubs, and HID/gamepad/touch devices
- Device list with search
  - Shows vendor/product names when known, plus VID:PID and basic class info
  - Text search across vendor, product, id string, and device path
- Detailed device view
  - Full device and configuration/endpoint breakdown (classes, subclasses, protocols)
  - Human‑readable names for USB class/subclass/protocol when available
  - Copy any field, view raw JSON payload, and neatly wrapped hex where applicable
- Device history
  - Maintains a chronological history of attach events; drill into past entries
  - Export/import history as JSON from the Settings screen
- Theming and UX
  - Material 3 design, light/dark theme, optional Android dynamic color support
  - Polished section cards, key/value rows, and snack‑bar copy confirmations
- Offline USB IDs database
  - Bundled SQLite database provides vendor/product/class lookups
  - Update controller coordinates DB refresh gating and metadata verification


### Technical/architectural
- Flutter + Riverpod 3
  - State: Notifier/AsyncNotifier providers for search, lists, settings, and details
  - Routing: go_router with named routes: Home, Device details, History (+ entry detail), Settings
- Platform channel bridge (Android)
  - Kotlin glue (UsbBridge) exposes:
    - MethodChannel: listDevices, getDeviceDetails, requestPermission, setUsbAttachComponentEnabled
    - EventChannel: usb attach/detach/connect/disconnect events
  - MainActivity wires pending intents and forwards onNewIntent to the bridge
- Repository + data layers
  - UsbPlatformService (Dart) wraps method/event channels
  - UsbRepository enriches platform data with lookups from UsbIdsDb
  - Providers compose platform, repository, and DB future
- USB IDs database
  - assets/db/usbids.sqlite shipped with the app
  - UsbIdsDb exposes vendorName/productName/class/subclass/protocol lookups with small caches
  - Tools (Python) to regenerate DB from assets/db_src/usbids.sql
    - tools/update_usbids_artifacts.py builds the SQL from upstream data
    - tools/build_usbids_db.py compiles the SQL into SQLite, with WAL/SHM cleanup
- UX components
  - Reusable SectionCard and KeyValueRow widgets for consistent layout
  - Formatters for hex/dec, labels, hex wrapping, and misc helpers
- Preferences
  - SharedPreferences for theme mode, dynamic color toggle, and USB auto‑attach behavior


### How it works (high‑level)
1. On app start, Riverpod initializes:
   - USB event coordinator and USB IDs auto‑check coordinator
   - Preference controllers (theme mode, dynamic color, USB attach behavior)
2. The Android bridge streams USB attach/detach events over an EventChannel.
3. The usbEventCoordinator listens for events and:
   - Ensures the USB IDs DB is available
   - Refreshes the device list
   - On attach, records a history entry and optionally navigates to the device details screen
   - On detach, returns to Home if the auto‑opened device was unplugged
4. Views bind to providers:
   - Home shows the enriched list (UsbRepository + UsbIdsDb)
   - Device detail fetches full descriptor data then enriches class/name fields
   - History pages display recorded entries; Settings offers export/import and preferences


## Installation
1. Download the APK:

[<img src="https://raw.githubusercontent.com/pioug/google-play-badges/06ccd9252af1501613da2ca28eaffe31307a4e6d/svg/English.svg"
     alt="Get it on Google Play"
     height="80">](https://play.google.com/store/apps/details?id=org.kaijinlab.usbdevinfo)

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="113">](https://f-droid.org/en/packages/org.kaijinlab.usbdevinfo/)

Or download the latest APK from the Releases Section.

2. Install the Application:
   - Enable installation from unknown sources if needed.
   - Follow the on‑screen instructions.

3. Launch and Configure:
   - Optionally enable dynamic color and choose light/dark/system theme
   - Decide whether the app should auto‑open on USB attach (Settings)
   - Plug in a USB device and grant permission when prompted


## Build from source
- Requirements
  - Flutter SDK (Dart 3.x), Android SDK/NDK as needed, a device/emulator running Android
- Steps
  - flutter pub get
  - flutter build apk (or flutter run for development)

The app bundles assets/db/usbids.sqlite. If you need to refresh the USB IDs data:
- Update assets/db_src/usbids.sql (or regenerate it via tools/update_usbids_artifacts.py)
- Run: python3 tools/build_usbids_db.py


## Permissions and compatibility
- Uses Android's USB host APIs; user permission prompts appear for certain device interactions
- Works offline for lookups once installed (DB is local)
- Dynamic color support is enabled by default on Android


## Project structure (high‑level)
- lib/
  - core/: routing, theme, preferences, USB event coordination, widgets, utils
  - data/: platform bridge wrapper, repository, DB layer, providers
  - features/: home, device detail, history, settings (and subcontrollers)
- android/: Kotlin bridge (UsbBridge), activity configuration, and intent plumbing
- assets/: USB IDs SQLite DB and sources
- tools/: scripts to rebuild and update the USB IDs database


## Screenshots

<img width="180" height="400" alt="1" src="https://github.com/user-attachments/assets/7838f3c6-0d38-48e6-8c12-97bf501fc813" />
<img width="180" height="400" alt="2" src="https://github.com/user-attachments/assets/572f194e-2859-4762-819e-03aabe22704b" />
<img width="180" height="400" alt="3" src="https://github.com/user-attachments/assets/89c07279-a80b-4ca7-9409-a3aa6be4f39a" />
<img width="180" height="400" alt="4" src="https://github.com/user-attachments/assets/96d156e2-33af-434c-8af3-03e0ee2f74ae" />
<img width="180" height="400" alt="5" src="https://github.com/user-attachments/assets/97cc02dc-696a-465f-b5f8-9cca3533e2c5" />

## Contributing

Contributions are welcome.

If you:

-   Find a bug
-   Have a feature request
-   Want to improve UI, parsing, or USB coverage

Open an issue or submit a pull request.

## License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

## Credits

-   USB vendor and product data sourced from the public `usb.ids` database

## More Apps by KaijinLab!

| App                                                               | What it does                                                                   |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| **[IR Blaster](https://github.com/iodn/android-ir-blaster)**      | Control and test infrared functionality for compatible devices.                |
| **[USBDevInfo](https://github.com/iodn/android-usb-device-info)** | Inspect USB device details and behavior to understand what's really connected. |
| **[GadgetFS](https://github.com/iodn/gadgetfs)**          | Experiment with USB gadget functionality (hardware-adjacent, low-level).       |
| **[TapDucky](https://github.com/iodn/tap-ducky)**                  | A security/testing tool for controlled keystroke injection workflows.          |
| **[HIDWiggle](https://github.com/iodn/hid-wiggle)**                | A mouse jiggler built with reliability and clean UX in mind.                   |

