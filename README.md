# USBDevInfo - USB Device Inspector for Android

**USBDevInfo** is an Android application for discovering, inspecting, and analyzing USB devices connected to your phone or tablet.  
It exposes the same low-level USB information that Android sees, but presents it in a clear, structured, and human-readable way.

The app is designed for developers, reverse-engineers, hardware hackers, and power users who need to understand exactly what a USB device reports: vendor IDs, configurations, interfaces, endpoints, HID descriptors, power requirements, and more.

USBDevInfo works fully offline, stores all data locally, and never transmits device information to any server.

## Overview

-   Live discovery of USB devices connected via OTG, hubs, or accessories
    
-   Full USB descriptor inspection (device, configuration, interface, endpoint)
    
-   HID and input device analysis (keyboards, mice, gamepads, etc.)
    
-   Built-in offline USB ID database for vendor and product name resolution
    
-   Per-device permission model that matches Android’s USB security system
    
-   Persistent device history for fast comparison and debugging
    

## Features

### USB device inspection

-   Detect all connected USB devices in real time
    
-   Display Vendor ID (VID) and Product ID (PID)
    
-   Resolve vendor and product names from the built-in `usb.ids` database
    
-   Show device class, subclass, and protocol
    

### Detailed descriptor view

-   USB specification version and negotiated speed
    
-   Configurations, interfaces, and endpoint layouts
    
-   Maximum power draw and power attributes
    
-   Raw device descriptor fields when permission is granted
    

### HID & input devices

-   Detect keyboards, mice, joysticks, and other HID devices
    
-   Show Android input sources (keyboard, mouse, joystick, touch, etc.)
    
-   Display motion axes and ranges for advanced controllers
    
-   Parse HID report descriptors and provide a readable summary
    

### Advanced device data (with permission)

-   String descriptors (manufacturer, product, serial, interface strings)
    
-   Raw descriptor tree parsed into structured fields
    
-   Device state queries:
    
    -   GET_STATUS
        
    -   GET_CONFIGURATION
        
    -   GET_INTERFACE (where supported)
        

### Device history

-   Automatically records every inspected device
    
-   Reopen previous devices even after disconnect
    
-   Search by name, VID:PID, serial, or device path
    
-   Remove or restore history entries
    

### Permission-aware design

-   Clearly indicates when Android USB permission is required
    
-   Explains why some fields are unavailable without permission
    
-   Permissions are requested per device, not globally
    

### Offline USB ID database

-   Ships with a built-in USB vendor/product database
    
-   No dependency on online services at runtime
    
-   Optional manual database update from Settings
    

## Privacy

USBDevInfo is designed for sensitive environments.

-   No analytics
    
-   No telemetry
    
-   No network access for device data
    
-   All history is stored locally on your device
    
-   USB descriptors are never uploaded or shared
    

## Typical use cases

-   Identify unknown USB devices
    
-   Debug OTG cables, hubs, and adapters
    
-   Verify VID/PID and interface layouts
    
-   Inspect HID devices and controllers
    
-   Reverse-engineer USB accessories
    
-   Validate that a device is enumerating correctly
    

## Requirements

-   Android device with USB host (OTG) support
    
-   USB permission is required **per device** to access:
    
    -   Manufacturer and product strings
        
    -   Serial numbers
        
    -   Raw USB descriptors
        
    -   HID report descriptors
        

## Installation

1.  Download from Google Play:

[<img src="https://raw.githubusercontent.com/pioug/google-play-badges/06ccd9252af1501613da2ca28eaffe31307a4e6d/svg/English.svg"
     alt="Get it on Google Play"
     height="80">](https://play.google.com/store/apps/details?id=org.kaijinlab.usbdevinfo)
    

Or download the latest APK from the Releases section.

2.  Install the application:
    
    -   Enable installation from unknown sources if needed.
        
    -   Follow the on-screen instructions.
        
3.  Launch and connect a USB device:
    
    -   Plug in a USB device via OTG or hub.
        
    -   Grant permission when prompted.
        
    -   Tap the device to inspect its details.
        

## Usage

1.  Connect a USB device.
    
2.  Open USBDevInfo.
    
3.  Select the device from the list.
    
4.  Grant permission if requested.
    
5.  Explore:
    
    -   Descriptors
        
    -   Interfaces
        
    -   Endpoints
        
    -   HID and input data
        
    -   Power and configuration details
        

Previously connected devices remain available in the History view.

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