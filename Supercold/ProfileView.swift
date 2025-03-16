import SwiftUI

struct ProfileView: View {
    // Environment object to access shared data
    @EnvironmentObject private var calendarData: CalendarData
    
    // State variables
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isDeleteButtonVisible: Bool = false
    @State private var notificationsEnabled: Bool = true
    @State private var coldShowerReminders: Bool = true
    
    var body: some View {
        ZStack {
            // Background - bright blue background
            Color(red: 0.0, green: 0.5, blue: 1.0)
                .ignoresSafeArea()
            
            // Main container
            ScrollView {
                VStack(spacing: 25) {
                    // Stats Section
                    statsSection
                    
                    // Settings Section
                    settingsSection
                    
                    // App Info Section
                    appInfoSection
                    
                    // Reset Data Section
                    resetDataSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog("Are you sure you want to reset all data? This action cannot be undone.", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Reset All Data", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - View Components
    
    // Stats section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section title
            Text("Your Stats")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .padding(.leading, 15)
                .padding(.top, 15)
            
            // Stats rows
            VStack(spacing: 15) {
                // Current streak
                HStack {
                    Text("Current Streak")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("\(calendarData.calculateStreak()) days")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 15)
                
                Divider()
                    .background(Color.black.opacity(0.3))
                    .padding(.horizontal, 15)
                
                // Total cold showers
                HStack {
                    Text("Total Cold Showers")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("\(calendarData.completedDays.count)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 15)
                
                Divider()
                    .background(Color.black.opacity(0.3))
                    .padding(.horizontal, 15)
                
                // Most common mood
                HStack {
                    Text("Most Common Mood")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text(getMostCommonMood())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
            }
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
    }
    
    // Settings section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section title
            Text("Settings")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .padding(.leading, 15)
                .padding(.top, 15)
            
            // Settings rows
            VStack(spacing: 15) {
                // Notifications toggle
                Toggle(isOn: $notificationsEnabled) {
                    Text("Notifications")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.cyan))
                .padding(.horizontal, 15)
                
                Divider()
                    .background(Color.black.opacity(0.3))
                    .padding(.horizontal, 15)
                
                // Cold shower reminders toggle
                Toggle(isOn: $coldShowerReminders) {
                    Text("Daily Reminders")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.cyan))
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
            }
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
    }
    
    // App info section
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section title
            Text("About")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .padding(.leading, 15)
                .padding(.top, 15)
            
            // Info rows
            VStack(spacing: 15) {
                // Version
                HStack {
                    Text("Version")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 15)
                
                Divider()
                    .background(Color.black.opacity(0.3))
                    .padding(.horizontal, 15)
                
                // Developer
                HStack {
                    Text("Developer")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("Oumar Ka")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 15)
                
                Divider()
                    .background(Color.black.opacity(0.3))
                    .padding(.horizontal, 15)
                
                // Terms and Conditions
                Button(action: {
                    if let url = URL(string: "https://supercold.app/terms") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Text("Terms and Conditions")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
            }
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
    }
    
    // Reset data section
    private var resetDataSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section title
            Button(action: {
                withAnimation {
                    isDeleteButtonVisible.toggle()
                }
            }) {
                HStack {
                    Text("Reset Data")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: isDeleteButtonVisible ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(isDeleteButtonVisible ? 180 : 0))
                        .animation(.easeInOut, value: isDeleteButtonVisible)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
            }
            
            if isDeleteButtonVisible {
                VStack(spacing: 10) {
                    Text("This will reset all your cold shower data and cannot be undone.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                    
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Reset All Data")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(
                                ZStack {
                                    // Shadow rectangle
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black)
                                        .offset(x: 3, y: 3)
                                    
                                    // Main rectangle
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.black, lineWidth: 3)
                                        )
                                }
                            )
                    }
                    .padding(.bottom, 15)
                }
            }
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
    }
    
    // MARK: - Helper Functions
    
    // Function to get the most common mood
    private func getMostCommonMood() -> String {
        var moodCounts: [String: Int] = [:]
        
        // Count occurrences of each mood
        for (_, moods) in calendarData.moodData {
            for mood in moods {
                moodCounts[mood, default: 0] += 1
            }
        }
        
        // Find the mood with the highest count
        if let mostCommonMood = moodCounts.max(by: { $0.value < $1.value }) {
            return mostCommonMood.key
        }
        
        return "None yet"
    }
    
    // Function to reset all data
    private func resetAllData() {
        // Clear all completed days
        calendarData.completedDays.removeAll()
        
        // Clear all mood data
        calendarData.moodData.removeAll()
        
        // Force widget update
        calendarData.forceWidgetUpdate()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(CalendarData())
    }
} 