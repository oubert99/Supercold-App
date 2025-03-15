# Widget Sync and Avoiding Duplicate Elements

## Avoiding Duplicate Struct Definitions

One of the most common issues when working with widgets is having duplicate struct definitions across files. This can lead to compiler errors and unexpected behavior.

### Common Duplication Issues

1. **Duplicate View Structs**: Having the same view struct defined in multiple files
2. **Duplicate Widget Structs**: Having multiple widget structs with the same functionality
3. **Duplicate Entry Types**: Having multiple timeline entry types for the same data

### How to Avoid Duplicates

1. **Keep Related Code in the Same File**: 
   - Keep widget configuration, entry types, and view structs in the same file when they're closely related
   - Only separate code into different files when there's a clear separation of concerns

2. **Use Clear Naming Conventions**:
   - Use unique, descriptive names for your structs
   - Follow a consistent naming pattern (e.g., `WeeklyGridView`, `CompactWeeklyGridView`)

3. **Check for Duplicate Files**:
   - Regularly check your project for duplicate files
   - Delete any files that contain duplicate struct definitions

## Ensuring Proper Data Syncing

To ensure your widget always displays the most up-to-date data:

### 1. Use Shared UserDefaults

```swift
// In your main app
let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.Supercold")
sharedDefaults?.set(timeIntervals, forKey: "completedDays")
sharedDefaults?.synchronize()
```

### 2. Reload Widget Timelines

After updating data in the main app, reload the widget timelines:

```swift
WidgetCenter.shared.reloadAllTimelines()
```

### 3. Set Appropriate Timeline Update Policies

Choose the right timeline update policy based on your app's needs:

```swift
// Update at specific time (e.g., midnight)
let midnight = calendar.startOfDay(for: Date().addingTimeInterval(86400))
let timeline = Timeline(entries: [entry], policy: .after(midnight))

// Update after a time interval
let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))

// Update when the system decides (for less critical updates)
let timeline = Timeline(entries: [entry], policy: .atEnd)
```

## Weekly Grid vs. Yearly Grid

We've updated the widgets to use a weekly grid view instead of a yearly grid view:

### Benefits of Weekly Grid

1. **More Readable**: Shows days of the current week with larger dots
2. **More Relevant**: Focuses on recent activity rather than the entire year
3. **Better for Small Widgets**: Makes better use of limited space in small widgets

### Implementation

The weekly grid shows:
- The current week starting from Sunday
- Day indicators for each day of the week
- Highlighted dots for completed days
- A special indicator for the current day

## Testing Widget Sync

To test that your widget is properly syncing with the main app:

1. Run the main app and log a cold shower
2. Check that the data is saved to shared UserDefaults
3. Run the widget extension
4. Verify that the widget displays the updated data
5. If the widget doesn't update immediately, try removing and re-adding it

## Troubleshooting

If your widget isn't syncing properly:

1. **Check App Group Configuration**:
   - Ensure both the main app and widget extension have the same App Group capability
   - Verify the App Group identifier is consistent in both targets

2. **Verify UserDefaults Keys**:
   - Make sure you're using the same keys in both the app and widget
   - Check that data is being saved in the correct format

3. **Debug Widget Timeline**:
   - Add print statements in your timeline provider to verify data is being loaded
   - Check the timeline update policy to ensure it's appropriate for your needs

4. **Clear Cache if Needed**:
   - Sometimes you need to remove the widget and add it again
   - In extreme cases, restarting the device can help 