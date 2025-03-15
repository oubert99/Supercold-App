import SwiftUI
import WidgetKit

struct ColdShowerLogView: View {
    @State private var sliderValue: Double = 0
    @State private var sliderColor: Color = Color.white.opacity(0.7)
    @State private var sliderCompleted = false
    @State private var currentDate = Date()
    @State private var showMoodSelection: Bool = false
    @State private var selectedMoods: Set<String> = []
    @State private var contentOpacity: Double = 1.0
    @State private var moodSelectionOpacity: Double = 0.0
    @State private var showerCompleted: Bool = false
    @State private var showingDebugOptions = false
    
    // Environment object to access shared data (will be passed from parent view)
    @EnvironmentObject private var calendarData: CalendarData
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let moods = ["Energized", "Motivated", "Clear-minded", "Refreshed", "Focused", "Calm", "Strong"]
    
    var body: some View {
        ZStack {
            // Background - bright blue background
            Color(red: 0.0, green: 0.5, blue: 1.0)
                .ignoresSafeArea()
            
            // Main container
            VStack(spacing: 30) {
                // Neubrutalism container
                ZStack {
                    // Main content
                    mainContentView
                        .opacity(contentOpacity)
                    
                    // Mood selection overlay (in the same container)
                    if showMoodSelection {
                        moodSelectionView
                            .opacity(moodSelectionOpacity)
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
                .frame(width: UIScreen.main.bounds.width - 40)
                
                // Debug button (only visible in debug builds)
                #if DEBUG
                Button(action: {
                    showingDebugOptions = true
                }) {
                    Text("Debug Options")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 8)
                .actionSheet(isPresented: $showingDebugOptions) {
                    ActionSheet(
                        title: Text("Debug Options"),
                        message: Text("Widget debugging tools"),
                        buttons: [
                            .default(Text("Force Widget Update")) {
                                calendarData.forceWidgetUpdate()
                            },
                            .default(Text("Print Completed Days")) {
                                calendarData.printCompletedDays()
                            },
                            .cancel()
                        ]
                    )
                }
                #endif
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .onAppear {
            // Update current date when view appears
            currentDate = Date()
        }
    }
    
    // MARK: - Extracted Views
    
    // Main content view
    private var mainContentView: some View {
        VStack(spacing: 25) {
            // Current date text
            Text(dateFormatter.string(from: currentDate))
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .padding(.top, 30)
            
            if showerCompleted {
                completedView
            } else {
                loggerView
            }
        }
    }
    
    // Completed view with selected moods
    private var completedView: some View {
        VStack(spacing: 15) {
            // Success message
            Text("Congrats champ!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            // Selected moods
            if !selectedMoods.isEmpty {
                Text("Today you are feeling:")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 5)
                
                // Mood pills in a flow layout
                FlowLayout(spacing: 8) {
                    ForEach(Array(selectedMoods), id: \.self) { mood in
                        HStack {
                            Spacer()
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
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    // Logger view with slider
    private var loggerView: some View {
        VStack(spacing: 20) {
            // Slider
            sliderView
                .padding(.horizontal, 30)
                .padding(.top, 20)
            
            // Spacer to replace the removed buttons
            Spacer()
                .frame(height: 20)
        }
    }
    
    // Slider view
    private var sliderView: some View {
        VStack(spacing: 15) {
            Text("Slide to log your cold shower")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            ZStack(alignment: .leading) {
                // Slider track
                sliderTrack
                
                // Slider progress
                sliderProgress
                
                // Slider thumb
                sliderThumb
            }
            .frame(width: UIScreen.main.bounds.width * 0.7, height: 60)
            .padding(.vertical, 20)
        }
    }
    
    // Slider track
    private var sliderTrack: some View {
        ZStack {
            // Shadow rectangle
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .offset(x: 3, y: 3)
            
            // Main rectangle
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 3)
                )
                .overlay(
                    HStack {
                        Spacer()
                        Text("Slide to complete")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.trailing, 60)
                            .opacity(sliderCompleted ? 0 : 1)
                        Spacer()
                    }
                )
        }
    }
                                
    // Slider progress
    private var sliderProgress: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.cyan)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 3)
            )
            .frame(width: max(60, CGFloat(sliderValue) * UIScreen.main.bounds.width * 0.7), height: 60)
    }
                            
    // Slider thumb
    private var sliderThumb: some View {
        ZStack {
            // Shadow circle
            Circle()
                .fill(Color.black)
                .frame(width: 50, height: 50)
                .offset(x: 3, y: 3)
            
            // Main circle
            Circle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                )
                .overlay(
                    Image(systemName: sliderCompleted ? "checkmark" : "chevron.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                )
        }
        .offset(x: max(25, CGFloat(sliderValue) * (UIScreen.main.bounds.width * 0.7 - 50)))
        .gesture(
            DragGesture()
                .onChanged(onSliderDragChanged)
                .onEnded(onSliderDragEnded)
        )
    }
    
    // Mood selection view
    private var moodSelectionView: some View {
        VStack(spacing: 20) {
            Text("How do you feel?")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .padding(.top, 20)
            
            Text("Select up to 3 that apply")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.bottom, 5)
            
            // Mood selection pills - fixed alignment
            moodSelectionGrid
                .padding(.horizontal, 20)
            
            // Done button
            Button(action: saveMoodsAndShowCompleted) {
                Text("Done")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(width: 200)
                    .padding(.vertical, 15)
                    .background(
                        ZStack {
                            // Shadow rectangle
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black)
                                .offset(x: 3, y: 3)
                            
                            // Main rectangle
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.pink)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                    )
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
    }
    
    // Mood selection grid
    private var moodSelectionGrid: some View {
        VStack(alignment: .center, spacing: 15) {
            // First row
            HStack(spacing: 10) {
                MoodPillButton(
                    mood: moods[0],
                    isSelected: selectedMoods.contains(moods[0]),
                    action: { toggleMood(moods[0]) }
                )
                MoodPillButton(
                    mood: moods[1],
                    isSelected: selectedMoods.contains(moods[1]),
                    action: { toggleMood(moods[1]) }
                )
            }
            
            // Second row
            HStack(spacing: 10) {
                MoodPillButton(
                    mood: moods[2],
                    isSelected: selectedMoods.contains(moods[2]),
                    action: { toggleMood(moods[2]) }
                )
                MoodPillButton(
                    mood: moods[3],
                    isSelected: selectedMoods.contains(moods[3]),
                    action: { toggleMood(moods[3]) }
                )
            }
            
            // Third row
            HStack(spacing: 10) {
                MoodPillButton(
                    mood: moods[4],
                    isSelected: selectedMoods.contains(moods[4]),
                    action: { toggleMood(moods[4]) }
                )
                MoodPillButton(
                    mood: moods[5],
                    isSelected: selectedMoods.contains(moods[5]),
                    action: { toggleMood(moods[5]) }
                )
            }
            
            // Fourth row (single item centered)
            HStack {
                Spacer()
                MoodPillButton(
                    mood: moods[6],
                    isSelected: selectedMoods.contains(moods[6]),
                    action: { toggleMood(moods[6]) }
                )
                Spacer()
            }
        }
    }
    
    // MARK: - Event Handlers
    
    private func onSliderDragChanged(_ value: DragGesture.Value) {
        if !sliderCompleted {
            // Calculate slider value based on drag position
            let width = UIScreen.main.bounds.width * 0.7 - 50
            let newValue = min(1.0, max(0, Double(value.location.x - 25) / Double(width)))
            sliderValue = newValue
            
            // Check if slider is completed
            if newValue >= 0.95 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    sliderCompleted = true
                    sliderValue = 1.0
                    
                    // Log completion in calendar
                    logCompletionInCalendar()
                }
                
                // Show mood selection immediately without delays
                contentOpacity = 0
                showMoodSelection = true
                moodSelectionOpacity = 1.0
            }
        }
    }
    
    private func onSliderDragEnded(_ value: DragGesture.Value) {
        if !sliderCompleted {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                sliderValue = 0
            }
        }
    }
    
    private func toggleMood(_ mood: String) {
        if selectedMoods.contains(mood) {
            selectedMoods.remove(mood)
        } else {
            // Only add if we haven't reached the maximum of 3 moods
            if selectedMoods.count < 3 {
                selectedMoods.insert(mood)
            }
        }
    }
    
    private func logCompletionInCalendar() {
        // Add today's date to completed days in calendar
        calendarData.addCompletedDay(currentDate)
    }
    
    private func saveMoodsAndShowCompleted() {
        // Save the selected moods to the shared CalendarData
        calendarData.saveMoods(for: currentDate, moods: selectedMoods)
        
        // Fade out mood selection
        withAnimation(.easeInOut(duration: 0.5)) {
            moodSelectionOpacity = 0
        }
        
        // Hide mood selection and show completed view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showMoodSelection = false
            showerCompleted = true
            
            withAnimation(.easeInOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
        }
    }
            
    private func resetView() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showerCompleted = false
            sliderCompleted = false
            sliderValue = 0
        }
    }
}

// Mood pill button component
struct MoodPillButton: View {
    let mood: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(mood)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    ZStack {
                        // Shadow capsule
                        Capsule()
                            .fill(Color.black)
                            .offset(x: 3, y: 3)
                        
                        // Main capsule
                        Capsule()
                            .fill(isSelected ? Color.yellow : Color.white)
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                )
        }
    }
}

// Flow layout for mood pills
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            if x + viewSize.width > width {
                // Move to next row
                y += maxHeight + spacing
                x = 0
                maxHeight = 0
            }
            
            // Update position for next view
            x += viewSize.width + spacing
            maxHeight = max(maxHeight, viewSize.height)
        }
        
        // Add the height of the last row
        height = y + maxHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            if x + viewSize.width > bounds.maxX {
                // Move to next row
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
            }
            
            // Place the view
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height))
            
            // Update position for next view
            x += viewSize.width + spacing
            maxHeight = max(maxHeight, viewSize.height)
        }
    }
}

// CalendarData class to share data between views
class CalendarData: ObservableObject {
    @Published var completedDays: Set<Date> = [] {
        didSet {
            saveCompletedDaysToUserDefaults()
        }
    }
    @Published var moodData: [Date: Set<String>] = [:]
    
    init() {
        loadCompletedDaysFromUserDefaults()
    }
    
    func addCompletedDay(_ date: Date) {
        // Convert to start of day to ensure consistent date comparison
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        completedDays.insert(startOfDay)
        saveCompletedDaysToUserDefaults()
    }
    
    func saveMoods(for date: Date, moods: Set<String>) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        moodData[startOfDay] = moods
    }
    
    // Save completed days to UserDefaults for widget access
    private func saveCompletedDaysToUserDefaults() {
        // Save to app's UserDefaults
        let timeIntervals = completedDays.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(timeIntervals, forKey: "completedDays")
        
        // Save to shared UserDefaults for widget access
        let sharedDefaults = UserDefaults(suiteName: "group.com.oumar.Supercold")
        sharedDefaults?.set(timeIntervals, forKey: "completedDays")
        sharedDefaults?.synchronize()
        
        // Trigger widget update
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }
    
    // Load completed days from UserDefaults
    private func loadCompletedDaysFromUserDefaults() {
        if let savedDates = UserDefaults.standard.array(forKey: "completedDays") as? [Double] {
            completedDays = Set(savedDates.map { Date(timeIntervalSince1970: $0) })
        }
    }
    
    // Debug method to force widget update
    func forceWidgetUpdate() {
        print("Forcing widget update...")
        saveCompletedDaysToUserDefaults()
        
        // Print debug info
        print("App has \(completedDays.count) completed days")
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        for date in completedDays.sorted() {
            print("App completed day: \(formatter.string(from: date))")
        }
        
        // Calculate streak
        let streak = calculateStreak()
        print("App calculated streak: \(streak)")
        
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
            print("Widget timelines reloaded")
        }
        #endif
    }
    
    // Debug method to print completed days
    func printCompletedDays() {
        print("App has \(completedDays.count) completed days")
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        for date in completedDays.sorted() {
            print("App completed day: \(formatter.string(from: date))")
        }
        
        // Calculate streak
        let streak = calculateStreak()
        print("App calculated streak: \(streak)")
    }
    
    // Calculate streak using the same logic as the widget
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        let sortedDays = Array(completedDays).sorted()
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
}

struct ColdShowerLogView_Previews: PreviewProvider {
    static var previews: some View {
        ColdShowerLogView()
            .environmentObject(CalendarData())
    }
} 
