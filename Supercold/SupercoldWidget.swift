import WidgetKit
import SwiftUI

// MARK: - Widget Provider

struct Provider: TimelineProvider {
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
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.Supercold")
        var completedDays: Set<Date> = []
        
        if let savedDates = sharedDefaults?.array(forKey: "completedDays") as? [Double] {
            completedDays = Set(savedDates.map { Date(timeIntervalSince1970: $0) })
        }
        
        // Create an entry with the fetched data
        let entry = YearlyGridEntry(date: Date(), completedDays: completedDays)
        
        // Update once per day
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let midnight = calendar.startOfDay(for: Date().addingTimeInterval(86400))
        
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
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

struct SupercoldWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.0, green: 0.5, blue: 1.0)
            
            VStack(spacing: 8) {
                // Title
                Text("Cold Shower Tracker")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Year display
                Text(String(Calendar.current.component(.year, from: Date())))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                // Yearly grid
                YearlyGridWidgetView(
                    year: Calendar.current.component(.year, from: Date()),
                    completedDays: entry.completedDays
                )
                .padding(.horizontal, 8)
                
                // Streak count
                Text("\(streakCount) day streak")
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
            .padding(10)
        }
    }
    
    // Calculate streak count
    private var streakCount: Int {
        let calendar = Calendar.current
        let sortedDays = Array(entry.completedDays).sorted()
        var count = 0
        
        guard let lastCompletedDay = sortedDays.last else {
            return 0
        }
        
        var currentDate = lastCompletedDay
        
        while sortedDays.contains(where: { calendar.isDate($0, inSameDayAs: currentDate) }) {
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

// MARK: - Yearly Grid Widget View

struct YearlyGridWidgetView: View {
    let year: Int
    let completedDays: Set<Date>
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 31)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(daysInYear, id: \.self) { date in
                dayDot(for: date)
            }
        }
    }
    
    private func dayDot(for date: Date) -> some View {
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
                        lineWidth: 1
                    )
            )
            .frame(width: 4, height: 4)
    }
    
    private var daysInYear: [Date] {
        var days = [Date]()
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = 1
        dateComponents.day = 1
        
        guard let startOfYear = calendar.date(from: dateComponents) else {
            return days
        }
        
        // Check if it's a leap year
        let isLeapYear = calendar.range(of: .day, in: .year, for: startOfYear)!.count == 366
        let daysInYear = isLeapYear ? 366 : 365
        
        days.reserveCapacity(daysInYear) // Pre-allocate capacity for better performance
        
        for dayOffset in 0..<daysInYear {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfYear) {
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

struct SupercoldWidget: Widget {
    let kind: String = "SupercoldWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SupercoldWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Cold Shower Tracker")
        .description("Track your cold shower progress at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Widget Previews

struct SupercoldWidget_Previews: PreviewProvider {
    static var previews: some View {
        SupercoldWidgetEntryView(entry: YearlyGridEntry(
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