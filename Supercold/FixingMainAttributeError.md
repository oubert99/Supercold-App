# Fixing the '@main' Attribute Error

## The Error

You encountered the following errors:

```
'main' attribute can only apply to one type in a module
```

## What Caused This Error

This error occurs when you have multiple types marked with the `@main` attribute in the same module. In your case:

1. You had `@main struct SupercoldApp: App` in `SupercoldApp.swift` (in the main app module)
2. You also had `@main struct SupercoldWidgetBundle: WidgetBundle` in `SupercoldWidgetExtension.swift` (also in the main app module)

The problem is that the widget extension file was incorrectly placed in the main app module, when it should be in a separate widget extension target.

## How to Fix It

### Solution 1: Remove the Duplicate File (Quickest Fix)

1. Delete the `SupercoldWidgetExtension.swift` file from the main app module
2. Make sure the widget extension target has its own `SupercoldWidgetBundle.swift` file with the `@main` attribute

### Solution 2: Proper Widget Extension Setup (Best Practice)

1. Create a proper widget extension target in Xcode:
   - Go to File > New > Target
   - Select "Widget Extension"
   - Name it "SupercoldWidget"

2. Organize your files correctly:
   - Widget files should be in the widget extension target
   - App files should be in the main app target

3. Ensure each module has exactly one `@main` attribute:
   - Main app: `@main struct SupercoldApp: App`
   - Widget extension: `@main struct SupercoldWidgetBundle: WidgetBundle`

## Understanding Module Boundaries

In Swift, each target (like your main app or a widget extension) is a separate module. The `@main` attribute tells the compiler which type is the entry point for that module.

- You can only have one entry point per module
- Different modules can each have their own entry point

## Common Mistakes to Avoid

1. **Copying widget files into the main app target**: Widget files should only be in the widget extension target.

2. **Multiple @main declarations**: Check all your files to ensure only one type has the `@main` attribute in each module.

3. **Incorrect file organization**: Make sure your project navigator accurately reflects which files belong to which target.

## Checking Target Membership

To verify which target a file belongs to:

1. Select the file in the project navigator
2. Open the File Inspector (right panel)
3. Under "Target Membership", check which targets have the file selected

Files with the `@main` attribute should only be selected for one target each. 