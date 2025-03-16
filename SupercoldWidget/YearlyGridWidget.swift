import WidgetKit
import SwiftUI

// MARK: - Widget Provider

struct YearlyGridProvider: TimelineProvider {
    func placeholder(in context: Context) -> YearlyGridEntry {
        YearlyGridEntry(date: Date(), completedDays: sampleCompletedDays)
    }

    func getSnapshot(in context: Context, completion: @escaping (YearlyGridEntry) -> ()) {
        // For preview and when widget is added, show sample data
        let entry = YearlyGridEntry(date: Date(), completedDays: sampleCompletedDays)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<YearlyGridEntry>) -> ()) {
        // Get data from shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.oumar.Supercold")
        var completedDays: Set<Date> = []
        
        print("Widget timeline update requested")
        print("App group ID: group.com.oumar.Supercold")
        
        if let savedDates = sharedDefaults?.array(forKey: "completedDays") as? [Double] {
            completedDays = Set(savedDates.map { Date(timeIntervalSince1970: $0) })
            print("Widget loaded \(completedDays.count) completed days")
            
            // Debug: Print the dates to verify they're loading correctly
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            for date in completedDays.sorted() {
                print("Completed day: \(formatter.string(from: date))")
            }
        } else {
            print("Widget could not load completedDays from UserDefaults")
            print("Available keys in shared UserDefaults: \(sharedDefaults?.dictionaryRepresentation().keys.joined(separator: ", ") ?? "none")")
        }
        
        // Create an entry with the fetched data
        let entry = YearlyGridEntry(date: Date(), completedDays: completedDays)
        
        // Debug: Calculate streak
        let streak = calculateStreak(for: completedDays)
        print("Widget calculated streak: \(streak)")
        
        // Update once per day
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let midnight = calendar.startOfDay(for: Date().addingTimeInterval(86400))
        
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
    
    // Calculate streak - same logic as in the app
    private func calculateStreak(for completedDays: Set<Date>) -> Int {
        let calendar = Calendar.current
        let sortedDays = Array(completedDays).sorted()
        var count = 0
        
        guard let lastCompletedDay = sortedDays.last else {
            return 0
        }
        
        var currentDate = lastCompletedDay
        
        // This is the key difference - using firstIndex instead of contains
        while let _ = sortedDays.firstIndex(where: { calendar.isDate($0, inSameDayAs: currentDate) }) {
            count += 1
            
            // Check if the previous day exists in the completed days
            let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if !sortedDays.contains(where: { calendar.isDate($0, inSameDayAs: previousDay) }) {
                break
            }
            
            currentDate = previousDay
        }
        
        return count
    }
    
    // Sample data for previews
    private var sampleCompletedDays: Set<Date> {
        let calendar = Calendar.current
        let today = Date()
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: today))!
        
        var sampleDates: Set<Date> = []
        for i in 0..<365 where i % 3 == 0 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfYear) {
                sampleDates.insert(date)
            }
        }
        return sampleDates
    }
}

// MARK: - Widget Entry

struct YearlyGridEntry: TimelineEntry {
    let date: Date
    let completedDays: Set<Date>
}

// MARK: - Widget View

struct YearlyGridWidgetEntryView : View {
    var entry: YearlyGridProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(spacing: 8) {
            // Title
            Text("Cold Shower Tracker")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Week display
            Text("This Week")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            // Weekly grid
            WeeklyGridView(
                date: Date(),
                completedDays: entry.completedDays
            )
            .padding(.horizontal, 8)
            
            // Streak count - only show if streak > 1
            if streakCount > 1 {
                Text("\(streakCount) days super streak")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 10)
                    .background(
                        ZStack {
                            // Shadow rectangle
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black)
                                .offset(x: 2, y: 2)
                            
                            // Main rectangle
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.pink)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                    )
            }
        }
        .padding(10)
        .widgetURL(URL(string: "supercold://open"))
    }
    
    // Calculate streak - updated to match the app's calculation
    private var streakCount: Int {
        let calendar = Calendar.current
        let sortedDays = Array(entry.completedDays).sorted()
        var count = 0
        
        guard let lastCompletedDay = sortedDays.last else {
            return 0
        }
        
        var currentDate = lastCompletedDay
        
        // This is the key difference - using firstIndex instead of contains
        while let _ = sortedDays.firstIndex(where: { calendar.isDate($0, inSameDayAs: currentDate) }) {
            count += 1
            
            // Check if the previous day exists in the completed days
            let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if !sortedDays.contains(where: { calendar.isDate($0, inSameDayAs: previousDay) }) {
                break
            }
            
            currentDate = previousDay
        }
        
        return count
    }
}

// MARK: - Weekly Grid View

struct WeeklyGridView: View {
    let date: Date
    let completedDays: Set<Date>
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 4) {
            // Days of week header
            HStack(spacing: 8) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Week days
            HStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { date in
                    if let date = date {
                        dayDot(for: date)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
    }
    
    private func dayDot(for date: Date) -> some View {
        ZStack {
            Circle()
                .fill(
                    isCompleted(date) ? 
                        Color.cyan :
                        Color.gray.opacity(0.3)
                )
                .overlay(
                    Circle()
                        .stroke(
                            isToday(date) ? 
                                Color.white : 
                                Color.clear,
                            lineWidth: 2
                        )
                )
                .frame(width: 12, height: 12)
            
            // Day number
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private var weekDays: [Date?] {
        let today = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: today)
        let weekdayIndex = weekday - 1 // 0 = Sunday, 6 = Saturday
        
        // Get the start of the week (Sunday)
        let startOfWeek = calendar.date(byAdding: .day, value: -weekdayIndex, to: today)!
        
        var days = [Date?]()
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func isCompleted(_ date: Date) -> Bool {
        return completedDays.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func isToday(_ date: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: Date())
    }
}

// MARK: - Widget Configuration

struct YearlyGridWidget: Widget {
    let kind: String = "YearlyGridWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: YearlyGridProvider()) { entry in
            YearlyGridWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.0, green: 0.5, blue: 1.0)
                }
        }
        .configurationDisplayName("Cold Shower Tracker")
        .description("Track your cold shower progress at a glance.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

// MARK: - Widget Previews

struct YearlyGridWidget_Previews: PreviewProvider {
    static var previews: some View {
        YearlyGridWidgetEntryView(entry: YearlyGridEntry(
            date: Date(),
            completedDays: {
                let calendar = Calendar.current
                let today = Date()
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: today))!
                
                var sampleDates: Set<Date> = []
                for i in 0..<365 where i % 3 == 0 {
                    if let date = calendar.date(byAdding: .day, value: i, to: startOfYear) {
                        sampleDates.insert(date)
                    }
                }
                return sampleDates
            }()
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
} 