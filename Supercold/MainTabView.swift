import SwiftUI

struct MainTabView: View {
    @StateObject private var calendarData = CalendarData()
    
    var body: some View {
        TabView {
            ColdShowerLogView()
                .tabItem {
                    Label("Log", systemImage: "snowflake")
                }
            
            CalendarTrackerView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
            
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.bar.fill")
                }
        }
        .environmentObject(calendarData)
        .accentColor(.white)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 