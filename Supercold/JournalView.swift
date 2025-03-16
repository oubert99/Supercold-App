import SwiftUI

struct JournalView: View {
    // Environment object to access shared data
    @EnvironmentObject private var calendarData: CalendarData
    
    var body: some View {
        ZStack {
            // Background - bright blue background
            Color(red: 0.0, green: 0.5, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text("Journal")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Journal entries
                ScrollView {
                    VStack(spacing: 20) {
                        if journalEntries.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(journalEntries, id: \.date) { entry in
                                JournalEntryCard(entry: entry)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    // Empty state view when no entries exist
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text("No cold showers logged yet")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Your journal entries will appear here after you log your first cold shower")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(height: 400)
    }
    
    // Get sorted journal entries
    private var journalEntries: [JournalEntry] {
        // Get all dates with completed cold showers
        let completedDates = calendarData.completedDays
        
        // Create journal entries
        let entries = completedDates.map { date -> JournalEntry in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let moods = calendarData.moodData[startOfDay] ?? []
            return JournalEntry(date: date, moods: moods)
        }
        
        // Sort by date (newest first)
        return entries.sorted { $0.date > $1.date }
    }
}

// Journal entry model
struct JournalEntry {
    let date: Date
    let moods: Set<String>
}

// Journal entry card view
struct JournalEntryCard: View {
    let entry: JournalEntry
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            // Shadow rectangle
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)
                .offset(x: 8, y: 8)
            
            // Main rectangle
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 4)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 15) {
                // Date header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateFormatter.string(from: entry.date))
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text(weekdayFormatter.string(from: entry.date))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Snowflake icon
                    Image(systemName: "snowflake")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.cyan)
                        .padding(10)
                        .background(
                            ZStack {
                                // Shadow circle
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 44, height: 44)
                                    .offset(x: 3, y: 3)
                                
                                // Main circle
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 3)
                                    )
                            }
                        )
                }
                
                // Divider
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 2)
                
                // Moods section
                if entry.moods.isEmpty {
                    Text("No moods recorded")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.vertical, 5)
                } else {
                    Text("Moods:")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    // Mood pills
                    FlowLayout(spacing: 8) {
                        ForEach(Array(entry.moods), id: \.self) { mood in
                            Text(mood)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    ZStack {
                                        // Shadow capsule
                                        Capsule()
                                            .fill(Color.black)
                                            .offset(x: 2, y: 2)
                                        
                                        // Main capsule
                                        Capsule()
                                            .fill(Color.yellow)
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.black, lineWidth: 2)
                                            )
                                    }
                                )
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .environmentObject({
                let data = CalendarData()
                // Add some sample data
                data.addCompletedDay(Date())
                data.saveMoods(for: Date(), moods: ["Energized", "Motivated"])
                return data
            }())
    }
}
