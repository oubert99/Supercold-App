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
    
    private let moods = ["Super-Energized", "Super-Motivated", "Super-Clear-headed", "Super-Refreshed", "Super-Focused", "Super-Calm", "Super-Strong", "Super-Awake", "Super-Tough", "Super-Sharp", "Super-Brave", "Super-Alert", "Super-Happy", "Super-Relaxed", "Super-Warm inside", "Super-Fresh", "Super-Light", "Super-Confident", "Super-Alive", "Super-Powerful"]
    
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
                            .default(Text("Reset Slider")) {
                                resetView()
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
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.2).combined(with: .opacity)
                    ))
            } else {
                if showMoodSelection {
                    moodSelectionView
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.2).combined(with: .opacity)
                        ))
                } else {
                    loggerView
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.2).combined(with: .opacity)
                        ))
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showerCompleted)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showMoodSelection)
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
            .frame(width: CGFloat(sliderValue) * UIScreen.main.bounds.width * 0.7, height: 60)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: sliderValue)
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
        .offset(x: sliderValue * (UIScreen.main.bounds.width * 0.7 - 50))
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
        ScrollView {
            FlowLayout(spacing: 8) {
                ForEach(moods, id: \.self) { mood in
                    MoodPillButton(
                        mood: mood,
                        isSelected: selectedMoods.contains(mood),
                        action: { toggleMood(mood) }
                    )
                }
            }
            .padding(.vertical, 10)
        }
        .frame(maxHeight: 300)
    }
    
    // MARK: - Event Handlers
    
    private func onSliderDragChanged(_ value: DragGesture.Value) {
        if !sliderCompleted {
            // Calculate slider value based on drag position
            let width = UIScreen.main.bounds.width * 0.7 - 50
            let newValue = min(1.0, max(0, Double(value.location.x) / Double(width)))
            sliderValue = newValue
            
            // Check if slider is completed - now requires reaching 99.5% instead of 95%
            if newValue >= 0.995 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    sliderCompleted = true
                    sliderValue = 1.0
                    
                    // Log completion in calendar
                    logCompletionInCalendar()
                }
                
                // Show mood selection with morphing animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showMoodSelection = true
                }
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
            selectedMoods.insert(mood)
        }
    }
    
    private func logCompletionInCalendar() {
        // Add today's date to completed days in calendar
        calendarData.addCompletedDay(currentDate)
    }
    
    private func saveMoodsAndShowCompleted() {
        // Save the selected moods to the shared CalendarData
        calendarData.saveMoods(for: currentDate, moods: selectedMoods)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            moodSelectionOpacity = 0
            showMoodSelection = false
            showerCompleted = true
            contentOpacity = 1.0
        }
    }
            
    private func resetView() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showMoodSelection = false
            showerCompleted = false
            sliderCompleted = false
            sliderValue = 0
            contentOpacity = 1.0
            moodSelectionOpacity = 0
            selectedMoods.removeAll()
        }
    }
}

// Mood pill button component with animation
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
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
        var rowWidth: CGFloat = 0
        var rowViews: [LayoutSubviews.Element] = []
        
        // First pass: collect views for each row
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if x + viewSize.width > bounds.maxX {
                // Center the current row
                let rowCenter = bounds.midX
                let rowStart = rowCenter - rowWidth / 2
                
                // Place views in centered row
                var xPos = rowStart
                for rowView in rowViews {
                    let rowViewSize = rowView.sizeThatFits(.unspecified)
                    rowView.place(at: CGPoint(x: xPos, y: y), proposal: ProposedViewSize(width: rowViewSize.width, height: rowViewSize.height))
                    xPos += rowViewSize.width + spacing
                }
                
                // Move to next row
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
                rowWidth = 0
                rowViews = []
            }
            
            // Add to current row
            rowViews.append(view)
            rowWidth += viewSize.width + (rowViews.count > 1 ? spacing : 0)
            x += viewSize.width + spacing
            maxHeight = max(maxHeight, viewSize.height)
        }
        
        // Handle the last row
        if !rowViews.isEmpty {
            let rowCenter = bounds.midX
            let rowStart = rowCenter - rowWidth / 2
            
            var xPos = rowStart
            for rowView in rowViews {
                let rowViewSize = rowView.sizeThatFits(.unspecified)
                rowView.place(at: CGPoint(x: xPos, y: y), proposal: ProposedViewSize(width: rowViewSize.width, height: rowViewSize.height))
                xPos += rowViewSize.width + spacing
            }
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
    func calculateStreak() -> Int {
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
