# Supercold Widget Setup Summary

This document provides a comprehensive guide on how to set up and troubleshoot the widget extension for the Supercold app.

## Proper Widget Extension Setup

### 1. Create a Separate Widget Extension Target

The most important thing to understand is that a widget extension must be a **separate target** in your Xcode project, not part of the main app target.

To create a widget extension target:
1. In Xcode, go to File > New > Target
2. Select "Widget Extension" under the iOS tab
3. Name it "SupercoldWidget"
4. Make sure it's configured as a separate target from your main app

### 2. File Organization

Your widget files should be organized as follows:

**In the Widget Extension target:**
- `SupercoldWidgetBundle.swift` - Contains the `@main` entry point for the widget
- `YearlyGridWidget.swift` - Contains the regular widget implementation
- `AppIconYearlyGridWidget.swift` - Contains the app icon widget implementation

**In the Main App target:**
- `SupercoldApp.swift` - Contains the `@main` entry point for the main app

### 3. Avoid Duplicate @main Attributes

The `@main` attribute should only appear once in each module/target:
- In the main app: `@main struct SupercoldApp: App`
- In the widget extension: `@main struct SupercoldWidgetBundle: WidgetBundle`

If you see errors like `'main' attribute can only apply to one type in a module`, it means you have multiple `@main` declarations in the same module.

## App Groups for Data Sharing

To share data between your main app and widget:

1. Enable App Groups capability in both targets:
   - Select each target in Xcode
   - Go to "Signing & Capabilities"
   - Add the "App Groups" capability
   - Create a group named "group.com.yourcompany.Supercold"

2. Save data to shared UserDefaults:
   ```swift
   // In your main app
   let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.Supercold")
   sharedDefaults?.set(data, forKey: "completedDays")
   ```

3. Read data in your widget:
   ```swift
   // In your widget
   let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.Supercold")
   let data = sharedDefaults?.object(forKey: "completedDays")
   ```

## Troubleshooting Common Issues

### 1. Multiple @main Attributes

**Error:** `'main' attribute can only apply to one type in a module`

**Solution:** 
- Ensure widget files are in the widget extension target, not the main app target
- Remove any duplicate `@main` declarations

### 2. Widget Not Updating

**Possible causes and solutions:**
- App Groups not configured correctly - Check both targets have the same App Group
- Data not being saved to shared UserDefaults - Verify the save code is working
- Widget timeline not refreshing - Call `WidgetCenter.shared.reloadAllTimelines()` after data changes

### 3. Widget Not Appearing in Widget Gallery

**Possible causes and solutions:**
- Widget extension not properly configured - Check Info.plist settings
- Widget not built successfully - Check for build errors
- Device needs restart - Sometimes iOS needs a restart to recognize new widgets

## Testing Your Widget

1. Run the main app first to ensure it's installed
2. Then run the widget extension target to install the widget
3. Go to the home screen and add the widget using the standard iOS widget picker
4. Test both the regular widget and the app icon widget

Remember that widgets have limited interactivity - they can only perform simple actions when tapped, like opening the main app. 