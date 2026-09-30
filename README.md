# WakeUp

WakeUp is a small native macOS menu-bar app that prevents idle system sleep while still allowing the display to turn off.

Choose **5 Minutes**, **10 Minutes**, **15 Minutes**, or **Indefinitely** from the menu-bar icon. Choose **Allow Sleep** to stop early.

## Build and run

Requires macOS 13 or newer and Xcode Command Line Tools.

```sh
chmod +x build-app.sh
./build-app.sh
open dist/WakeUp.app
```

The generated app is at `dist/WakeUp.app`. Move it to `/Applications` if you want to keep it installed.

WakeUp has no Dock icon. Quit it from **Quit WakeUp** in its menu-bar menu.

## Share the app

Share the complete app bundle as a ZIP file, not the executable inside it:

```sh
ditto -c -k --keepParent dist/WakeUp.app dist/WakeUp.zip
```

You can then send `dist/WakeUp.zip` to another user. After extracting it, they can move `WakeUp.app` to their Applications folder.

The current build:

- Supports Apple Silicon Macs (`M1`, `M2`, `M3`, `M4`, and newer).
- Requires macOS 13 or newer.
- Is ad-hoc signed and is not notarized by Apple.

Because the app is not notarized, macOS may block it on first launch. The recipient can right-click `WakeUp.app`, select **Open**, and confirm that they want to open it.

Public distribution without this security warning requires an Apple Developer certificate and Apple notarization. Supporting Intel Macs also requires building a universal binary containing both `arm64` and `x86_64` architectures.
