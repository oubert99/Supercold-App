# Supercold Widget Setup Instructions

This document provides instructions on how to set up the widget extension for the Supercold app, which allows users to display their cold shower tracking data on their home screen.

## Setting Up the Widget Extension in Xcode

1. **Add a Widget Extension Target**:
   - Open your Xcode project
   - Go to File > New > Target
   - Select "Widget Extension" under the iOS tab
   - Name it "SupercoldWidget"
   - Make sure "Include Configuration Intent" is unchecked (we're using a static widget)
   - Click "Finish"

2. **Configure App Groups**:
   - Select your main app target
   - Go to the "Signing & Capabilities" tab
   - Click the "+" button to add a capability
   - Add "App Groups"
   - Click the "+" button under App Groups to add a new group
   - Name it "group.com.yourcompany.Supercold" (replace "yourcompany" with your actual bundle identifier prefix)
   - Repeat the same steps for the widget extension target

3. **Add the Widget Files**:
   - Add the following files to your widget extension target:
     - `SupercoldWidget.swift`
     - `SupercoldAppIconWidget.swift`
     - `SupercoldWidgetExtension.swift`

4. **Update Info.plist for the Widget**:
   - Open the Info.plist file for the widget extension
   - Make sure it has the following entries:
     - `NSExtension` > `NSExtensionPointIdentifier` = `com.apple.widgetkit-extension`

5. **Build and Run**:
   - Build and run the app
   - On your device or simulator, long-press on the home screen
   - Tap the "+" button to add a widget
   - Find "Supercold" in the widget list
   - Choose either the "Cold Shower Tracker" or "Cold Shower Icon" widget
   - Select the size (small is recommended)
   - Add to your home screen

## Using the Widget as an App Icon Alternative

The "Cold Shower Icon" widget is designed to be used as an alternative to the app icon. It displays:

1. A compact yearly grid showing all your cold shower days
2. Your current streak count
3. The app name

To use it effectively:

1. Add the "Cold Shower Icon" widget to your home screen
2. Place it where you would normally have your app icon
3. Move the actual app icon to a secondary home screen or app library

This gives you a live-updating "app icon" that shows your progress at a glance!

## Troubleshooting

If the widget isn't updating:

1. Make sure App Groups are properly configured
2. Check that the app is saving data to UserDefaults with the correct suite name
3. Try restarting your device
4. Remove and re-add the widget

## Technical Notes

- The widget uses a shared UserDefaults container to access data from the main app
- It updates once per day at midnight
- The widget displays data for the current year only 