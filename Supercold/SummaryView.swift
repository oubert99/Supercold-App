import SwiftUI

struct SummaryView: View {
    // Environment object to access shared data
    @EnvironmentObject private var calendarData: CalendarData
    
    var body: some View {
        ZStack {
            // Background - bright blue background
            Color(red: 0.0, green: 0.5, blue: 1.0)
                .ignoresSafeArea()
            
            // Main container
            VStack(spacing: 30) {
                // Neubrutalism container
                VStack(spacing: 0) {
                    // Content
                    VStack(alignment: .leading, spacing: 40) {
                        // Header
                        Text("Hi Oumar,")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                        
                        // Main text
                        Text(mainText)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .lineSpacing(8)
                        
                        // Footer
                        Text("Have a nice day.")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
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
                .frame(width: UIScreen.main.bounds.width - 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - Helper Methods
    
    private var mainText: AttributedString {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let monthName = DateFormatter().monthSymbols[currentMonth - 1]
        let currentYear = calendar.component(.year, from: currentDate)
        
        // Count occurrences of each mood
        var moodCounts: [String: Int] = [:]
        for (_, moods) in calendarData.moodData {
            for mood in moods {
                moodCounts[mood.lowercased(), default: 0] += 1
            }
        }
        
        // Format moods with "and" before the last item and include counts
        let formattedMoods: String
        if topMoods.isEmpty {
            formattedMoods = ""
        } else if topMoods.count == 1 {
            formattedMoods = "\(topMoods[0])"
        } else if topMoods.count == 2 {
            formattedMoods = "\(topMoods[0]) and \(topMoods[1])"
        } else {
            let allButLast = topMoods.dropLast().joined(separator: ", ")
            formattedMoods = "\(allButLast), and \(topMoods.last!)"
        }
        
        let moodsText = topMoods.isEmpty ? "" : " It made you \(formattedMoods)!"
        
        // Create dynamic text based on shower counts
        var baseText: String
        if yearlyShowerCount == 0 {
            baseText = "You did not take any cold shower yet! Try it :)"
        } else if monthlyShowerCount == 0 {
            baseText = "You took YEARLY_COUNT_PLACEHOLDER cold showers in YEAR_PLACEHOLDER, none this month yet!"
        } else {
            // Use placeholders for all numbers to avoid conflicts
            baseText = "You took YEARLY_COUNT_PLACEHOLDER cold showers in YEAR_PLACEHOLDER, MONTHLY_COUNT_PLACEHOLDER this month!\(moodsText)"
        }
        
        var attributedString = AttributedString(baseText)
        
        // Replace and style the yearly count placeholder
        if yearlyShowerCount > 0 {
            if let yearlyCountPlaceholderRange = attributedString.range(of: "YEARLY_COUNT_PLACEHOLDER") {
                let yearlyCountString = AttributedString("\(yearlyShowerCount)")
                var styledYearlyCountString = yearlyCountString
                styledYearlyCountString.font = .system(size: 32, weight: .black, design: .rounded)
                styledYearlyCountString.foregroundColor = .black
                
                attributedString.replaceSubrange(yearlyCountPlaceholderRange, with: styledYearlyCountString)
            }
            
            // Replace and style the year placeholder
            if let yearPlaceholderRange = attributedString.range(of: "YEAR_PLACEHOLDER") {
                let yearString = AttributedString("\(currentYear)")
                var styledYearString = yearString
                styledYearString.font = .system(size: 24, weight: .bold, design: .rounded)
                styledYearString.foregroundColor = .black
                
                attributedString.replaceSubrange(yearPlaceholderRange, with: styledYearString)
            }
        }
        
        // Replace and style the monthly count placeholder
        if monthlyShowerCount > 0 {
            if let monthlyCountPlaceholderRange = attributedString.range(of: "MONTHLY_COUNT_PLACEHOLDER") {
                let monthlyCountString = AttributedString("\(monthlyShowerCount)")
                var styledMonthlyCountString = monthlyCountString
                styledMonthlyCountString.font = .system(size: 32, weight: .black, design: .rounded)
                styledMonthlyCountString.foregroundColor = .black
                
                attributedString.replaceSubrange(monthlyCountPlaceholderRange, with: styledMonthlyCountString)
            }
        }
        
        // Apply bold to the moods and add superscript counts
        for mood in topMoods {
            if let moodRange = attributedString.range(of: mood) {
                attributedString[moodRange].font = .system(size: 24, weight: .black, design: .rounded)
                attributedString[moodRange].foregroundColor = .black
                
                // Add the count as a superscript if available
                if let count = moodCounts[mood] {
                    // Create a new attributed string for the count
                    var countString = AttributedString("\(count)")
                    countString.font = .system(size: 12, weight: .bold, design: .rounded)
                    countString.foregroundColor = .black
                    countString.baselineOffset = 8 // Raise it to superscript position
                    
                    // Insert the count after the mood
                    let insertionPoint = attributedString.index(moodRange.upperBound, offsetByCharacters: 0)
                    attributedString.insert(countString, at: insertionPoint)
                }
            }
        }
        
        return attributedString
    }
    
    private var monthlyShowerCount: Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        return calendarData.completedDays.filter { date in
            date >= startOfMonth && date <= currentDate
        }.count
    }
    
    private var yearlyShowerCount: Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: currentDate))!
        
        return calendarData.completedDays.filter { date in
            date >= startOfYear && date <= currentDate
        }.count
    }
    
    private var topMoods: [String] {
        // Default moods if no data available
        let defaultMoods = ["motivated", "energized", "clear-minded"]
        
        // Count occurrences of each mood
        var moodCounts: [String: Int] = [:]
        
        for (_, moods) in calendarData.moodData {
            for mood in moods {
                moodCounts[mood.lowercased(), default: 0] += 1
            }
        }
        
        // Sort moods by count and take top 3
        let sortedMoods = moodCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        return sortedMoods.isEmpty ? defaultMoods : Array(sortedMoods)
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
            .environmentObject(CalendarData())
    }
} 