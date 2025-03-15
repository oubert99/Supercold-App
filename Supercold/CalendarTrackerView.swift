import SwiftUI

struct CalendarTrackerView: View {
    @State private var viewMode: ViewMode = .weekly
    @State private var currentDate = Date()
    @State private var selectedDate: Date? = nil
    @State private var showMoodPopup = false
    
    // Use the shared CalendarData instead of local state
    @EnvironmentObject private var calendarData: CalendarData
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    enum ViewMode {
        case weekly, monthly, yearly
    }
    
    var body: some View {
        ZStack {
            // Background - bright blue background
            Color(red: 0.0, green: 0.5, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Neubrutalism container
                VStack(spacing: 16) {
                    // Toggle between view modes
                    HStack {
                        Picker("View Mode", selection: $viewMode.animation(.spring(response: 0.4, dampingFraction: 0.8))) {
                            Text("Weekly").tag(ViewMode.weekly)
                            Text("Monthly").tag(ViewMode.monthly)
                            Text("Yearly").tag(ViewMode.yearly)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .onAppear {
                            // Apply custom styling to the segmented control
                            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.cyan)
                            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 14)], for: .selected)
                            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 14)], for: .normal)
                        }
                        
                        Spacer()
                        
                        // Settings button
                        Button(action: {
                            // Settings action
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .bold))
                                .padding(10)
                                .background(
                                    ZStack {
                                        // Shadow rectangle
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black)
                                            .frame(width: 44, height: 44)
                                            .offset(x: 4, y: 4)
                                        
                                        // Main rectangle
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.yellow)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.black, lineWidth: 3)
                                            )
                                    }
                                )
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.top, 10)
                    
                    // Month navigation and display
                    HStack(alignment: .center) {
                        // Previous month/year button
                        Button(action: {
                            navigateToPrevious()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(
                                    ZStack {
                                        // Shadow circle
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 48, height: 48)
                                            .offset(x: 3, y: 3)
                                        
                                        // Main circle
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.black, lineWidth: 3)
                                            )
                                    }
                                )
                        }
                        .padding(.leading, 10)
                        
                        Spacer()
                        
                        // Month and year display
                        VStack(alignment: .center) {
                            Text(dateTitle)
                                .font(.system(size: viewMode == .yearly ? 40 : 45, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                            
                            Text("\(streakCount) day streak")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 15)
                                .background(
                                    ZStack {
                                        // Shadow rectangle
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black)
                                            .offset(x: 3, y: 3)
                                        
                                        // Main rectangle
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.pink)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.black, lineWidth: 3)
                                            )
                                    }
                                )
                        }
                        
                        Spacer()
                        
                        // Next month/year button
                        Button(action: {
                            navigateToNext()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(
                                    ZStack {
                                        // Shadow circle
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 48, height: 48)
                                            .offset(x: 3, y: 3)
                                        
                                        // Main circle
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.black, lineWidth: 3)
                                            )
                                    }
                                )
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.horizontal, 10)
                    
                    if viewMode == .weekly || viewMode == .monthly {
                        // Days of week header
                        HStack(spacing: 0) {
                            ForEach(daysOfWeek, id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 10)
                        
                        // Calendar grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                            ForEach(calendarDays, id: \.self) { date in
                                if let date = date {
                                    DayCell(
                                        date: date,
                                        isToday: calendar.isDate(date, inSameDayAs: Date()),
                                        isCompleted: calendarData.completedDays.contains { calendar.isDate($0, inSameDayAs: date) }
                                    )
                                    .onTapGesture {
                                        if calendarData.completedDays.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
                                            selectedDate = date
                                            showMoodPopup = true
                                        } else {
                                            // Add the day to completed days
                                            calendarData.completedDays.insert(date)
                                        }
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                    .id("day-\(date.timeIntervalSince1970)")
                                } else {
                                    // Empty cell for padding
                                    Color.clear
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewMode)
                    } else {
                        // Yearly view - ONE GRID of dots
                        VStack(spacing: 0) {
                            // Year grid - single grid of 365/366 dots
                            YearGridView(
                                year: calendar.component(.year, from: currentDate),
                                completedDays: calendarData.completedDays
                            )
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                        }
                        .padding(.bottom, 10)
                    }
                    
                    // Spacer to replace the removed bottom button
                    if viewMode != .yearly {
                        Spacer()
                            .frame(height: 15)
                    } else {
                        Spacer()
                            .frame(height: 5)
                    }
                }
                .padding(.vertical, 20)
                .background(
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
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            // Mood popup
            if showMoodPopup, let date = selectedDate {
                MoodPopupView(
                    date: date,
                    moods: calendarData.moodData[calendar.startOfDay(for: date)] ?? [],
                    isShowing: $showMoodPopup
                )
            }
        }
        .onAppear {
            calculateStreak()
        }
    }
    
    private var dateTitle: String {
        let formatter = DateFormatter()
        
        if viewMode == .yearly {
            formatter.dateFormat = "yyyy"
            return formatter.string(from: currentDate)
        } else {
            formatter.dateFormat = "MMMM"
            let month = formatter.string(from: currentDate)
            
            if viewMode == .monthly {
                formatter.dateFormat = "yyyy"
                let year = formatter.string(from: currentDate)
                return "\(month) \(year)"
            }
            
            return month
        }
    }
    
    private var monthAbbreviations: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return (1...12).compactMap { month in
            var components = DateComponents()
            components.year = 2023 // Any year will do
            components.month = month
            components.day = 1
            if let date = calendar.date(from: components) {
                return formatter.string(from: date)
            }
            return nil
        }
    }
    
    private var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        var days = formatter.shortWeekdaySymbols ?? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        // Adjust if your week starts with Monday
        // days.append(days.removeFirst())
        
        return days
    }
    
    private var calendarDays: [Date?] {
        if viewMode == .weekly {
            return weeklyCalendarDays
        } else {
            return monthlyCalendarDays
        }
    }
    
    private var weeklyCalendarDays: [Date?] {
        let today = calendar.startOfDay(for: currentDate)
        let weekday = calendar.component(.weekday, from: today)
        let weekdayIndex = weekday - 1
        
        // Get the start of the week (Sunday or Monday depending on locale)
        let startOfWeek = calendar.date(byAdding: .day, value: -weekdayIndex, to: today)!
        
        var days = [Date?]()
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private var monthlyCalendarDays: [Date?] {
        let date = calendar.startOfDay(for: currentDate)
        let monthRange = calendar.range(of: .day, in: .month, for: date)!
        let daysInMonth = monthRange.count
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Adjust for weekday index (1-based in Calendar)
        let weekdayIndex = firstWeekday - 1
        
        var days = [Date?](repeating: nil, count: weekdayIndex)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Fill the remaining cells to complete the grid
        let remainingCells = (7 - (days.count % 7)) % 7
        days.append(contentsOf: [Date?](repeating: nil, count: remainingCells))
        
        return days
    }
    
    private func navigateToPrevious() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            switch viewMode {
            case .weekly:
                currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
            case .monthly:
                currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
            case .yearly:
                currentDate = calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate
            }
        }
    }
    
    private func navigateToNext() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            switch viewMode {
            case .weekly:
                currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
            case .monthly:
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
            case .yearly:
                currentDate = calendar.date(byAdding: .year, value: 1, to: currentDate) ?? currentDate
            }
        }
    }
    
    private var streakCount: Int {
        let sortedDays = calendarData.completedDays.sorted()
        var count = 0
        
        guard let lastCompletedDay = sortedDays.last else {
            return 0
        }
        
        var currentDate = lastCompletedDay
        
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
    
    private func calculateStreak() {
        // This is now a computed property, so we don't need this function
        // But we keep it for compatibility with onAppear
    }
}

// Year grid view for yearly view - ONE GRID of dots
struct YearGridView: View {
    let year: Int
    let completedDays: Set<Date>
    @EnvironmentObject private var calendarData: CalendarData
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 31)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(daysInYear, id: \.self) { date in
                    dayDot(for: date)
                }
            }
        }
        .frame(height: 180)
    }
    
    private func dayDot(for date: Date) -> some View {
        Circle()
            .fill(
                isCompleted(date) ? 
                    Color.blue :
                    Color.gray.opacity(0.3)
            )
            .overlay(
                Circle()
                    .stroke(
                        isToday(date) ? 
                            Color.black : 
                            Color.clear,
                        lineWidth: 2
                    )
            )
            .frame(width: 8, height: 8)
            .onTapGesture {
                if !isCompleted(date) {
                    // Add the day to completed days
                    calendarData.addCompletedDay(date)
                }
            }
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

// Day cell for weekly and monthly views
struct DayCell: View {
    let date: Date
    let isToday: Bool
    let isCompleted: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            // Shadow rectangle
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
                .offset(x: 3, y: 3)
            
            // Main rectangle
            RoundedRectangle(cornerRadius: 8)
                .fill(isCompleted ? Color.cyan : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 3)
                )
            
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                if isCompleted {
                    Image(systemName: "snowflake")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 2)
                } else {
                    Spacer()
                        .frame(height: 12)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// Mood popup view
struct MoodPopupView: View {
    let date: Date
    let moods: Set<String>
    @Binding var isShowing: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isShowing = false
                    }
                }
            
            // Popup content
            VStack(spacing: 20) {
                // Date
                Text(dateFormatter.string(from: date))
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                // Divider
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 3)
                    .padding(.horizontal, 20)
                
                if moods.isEmpty {
                    Text("No moods recorded")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                } else {
                    // Moods
                    Text("Moods")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    // Mood pills
                    FlowLayout(spacing: 8) {
                        ForEach(Array(moods), id: \.self) { mood in
                            Text(mood)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    ZStack {
                                        // Shadow capsule
                                        Capsule()
                                            .fill(Color.black)
                                            .offset(x: 3, y: 3)
                                        
                                        // Main capsule
                                        Capsule()
                                            .fill(Color.yellow)
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.black, lineWidth: 3)
                                            )
                                    }
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Close button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isShowing = false
                    }
                }) {
                    Text("Close")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(
                            ZStack {
                                // Shadow rectangle
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black)
                                    .offset(x: 3, y: 3)
                                
                                // Main rectangle
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.pink)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.black, lineWidth: 3)
                                    )
                            }
                        )
                }
                .padding(.top, 10)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .background(
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
                }
            )
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .transition(.opacity.combined(with: .scale))
        }
    }
}

// Flow layout for mood pills


struct CalendarTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarTrackerView()
            .environmentObject(CalendarData())
    }
} 
