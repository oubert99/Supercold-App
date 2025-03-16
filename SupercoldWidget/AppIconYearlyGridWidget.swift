import WidgetKit
import SwiftUI

// MARK: - App Icon Widget

struct AppIconYearlyGridWidget: Widget {
    let kind: String = "AppIconYearlyGridWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: YearlyGridProvider()) { entry in
            AppIconWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("Cold Shower Icon")
        .description("Use as an alternative app icon with live tracking.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

// MARK: - App Icon Widget View

struct AppIconWidgetEntryView: View {
    var entry: YearlyGridProvider.Entry
    
    var body: some View {
        ZStack {
            // Background with rounded corners
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.0, green: 0.5, blue: 1.0))
            
            VStack(spacing: 5) {
                // App name at top
                Text("Supercold")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                // Weekly grid - compact version
                CompactWeeklyGridView(
                    date: Date(),
                    completedDays: entry.completedDays
                )
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                
                // Streak count at bottom - only show if streak > 1
                if streakCount > 1 {
                    Text("\(streakCount) days")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(
                            ZStack {
                                // Shadow rectangle
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.black)
                                    .offset(x: 1, y: 1)
                                
                                // Main rectangle
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.pink)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                        )
                }
            }
            .padding(5)
        }
        .widgetURL(URL(string: "supercold://open"))
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

// MARK: - Compact Weekly Grid View

struct CompactWeeklyGridView: View {
    let date: Date
    let completedDays: Set<Date>
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 2) {
            // Week days
            HStack(spacing: 4) {
                ForEach(weekDays, id: \.self) { date in
                    if let date = date {
                        dayDot(for: date)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 8, height: 8)
                    }
                }
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
                            Color(red: 1.0, green: 0.4, blue: 0.7) : 
                            Color.clear,
                        lineWidth: 1.5
                    )
            )
            .frame(width: 8, height: 8)
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

// MARK: - App Icon Widget Previews

struct AppIconYearlyGridWidget_Previews: PreviewProvider {
    static var previews: some View {
        AppIconWidgetEntryView(entry: YearlyGridEntry(
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