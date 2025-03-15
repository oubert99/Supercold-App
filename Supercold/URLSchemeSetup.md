# Setting Up URL Scheme for Widget Taps

To enable tapping on the widget to open your app, you need to register a custom URL scheme in your app's Info.plist file. Follow these steps:

## 1. Open Info.plist in Xcode

Open your main app's Info.plist file in Xcode.

## 2. Add URL Types

1. Right-click in the Info.plist editor and select "Add Row"
2. Select "URL types" from the dropdown menu
3. Click the disclosure triangle next to "URL types" to expand it
4. Click the "+" button to add a new URL type
5. Expand the newly added "Item 0" under URL types

## 3. Configure URL Scheme

Add the following values:
- URL identifier: `com.yourcompany.Supercold` (replace with your actual bundle identifier)
- URL Schemes: Click the "+" button and add `supercold`

Your Info.plist should now have an entry that looks like this:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.Supercold</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>supercold</string>
        </array>
    </dict>
</array>
```

## 4. Test the URL Scheme

You can test the URL scheme by:

1. Running your app on a device or simulator
2. Opening Safari
3. Typing `supercold://open` in the address bar
4. Your app should launch when you navigate to this URL

## 5. Widget Integration

The widgets have already been configured to use this URL scheme with:

```swift
.widgetURL(URL(string: "supercold://open"))
```

This means that when a user taps on the widget, iOS will open your app using the `supercold://open` URL.

## 6. Handling the URL in Your App

The app has been configured to handle this URL with the `onOpenURL` modifier:

```swift
.onOpenURL { url in
    if url.scheme == "supercold" {
        print("App opened from widget")
        // You can add specific navigation logic here if needed
    }
}
```

You can extend this to perform specific actions when the app is opened from a widget, such as navigating to a particular view. 