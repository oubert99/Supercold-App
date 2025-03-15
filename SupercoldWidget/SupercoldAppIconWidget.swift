import WidgetKit
import SwiftUI

// MARK: - App Icon Widget

struct SupercoldAppIconWidget: Widget {
    let kind: String = "SupercoldAppIconWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AppIconWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Cold Shower Icon")
        .description("Use as an alternative app icon with live tracking.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - App Icon Widget View

struct AppIconWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.0, green: 0.5, blue: 1.0)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(spacing: 5) {
                // App name at top
                Text("Supercold")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                // Yearly grid - compact version
                CompactYearlyGridView(
                    year: Calendar.current.component(.year, from: Date()),
                    completedDays: entry.completedDays
                )
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                
                // Streak count at bottom
                Text("\(streakCount)d")
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
            .padding(5)
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

// MARK: - Compact Yearly Grid View

struct CompactYearlyGridView: View {
    let year: Int
    let completedDays: Set<Date>
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 24)
    
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
                        lineWidth: 0.5
                    )
            )
            .frame(width: 3, height: 3)
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

// MARK: - App Icon Widget Previews

struct SupercoldAppIconWidget_Previews: PreviewProvider {
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