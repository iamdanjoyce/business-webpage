# MyApp

A native iOS app built with SwiftUI.

## Requirements

- Xcode 16 or later
- iOS 17.0+ deployment target

## Getting started

```bash
open MyApp.xcodeproj
```

Then pick an iOS Simulator and press **Run** (⌘R). Tests run with **⌘U**.

## Layout

| Path | Purpose |
| --- | --- |
| `MyApp/MyAppApp.swift` | App entry point (`@main`) |
| `MyApp/ContentView.swift` | Root view — start editing here |
| `MyApp/Assets.xcassets` | App icon, accent color, image assets |
| `MyApp/Preview Content/` | Assets used only by SwiftUI previews |
| `MyAppTests/` | Unit tests (Swift Testing) |
| `scripts/generate_xcodeproj.rb` | One-time bootstrap that created `MyApp.xcodeproj` |

## Regenerating the project file

`MyApp.xcodeproj` is committed and, once opened in Xcode, is the source of truth.
The generator script exists only to recreate the project from scratch if needed:

```bash
gem install xcodeproj --user-install
ruby scripts/generate_xcodeproj.rb
```

## Renaming from "MyApp"

Placeholder identifiers to change when the app gets a real name:

- Target and scheme names (`MyApp`, `MyAppTests`)
- `PRODUCT_BUNDLE_IDENTIFIER` — currently `com.example.MyApp`
- The `MyAppApp` struct and its file name
- This file, and values in `scripts/generate_xcodeproj.rb`
