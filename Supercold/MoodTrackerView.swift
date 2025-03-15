import SwiftUI

struct MoodTrackerView: View {
    @State private var selectedMood: Mood?
    @State private var energyLevel: Double = 5
    @State private var focusLevel: Double = 5
    @State private var recoveryLevel: Double = 5
    @State private var coldShowerDuration: TimeInterval = 60
    @State private var notes: String = ""
    @State private var showingSavedConfirmation = false
    
    enum Mood: String, CaseIterable, Identifiable {
        case amazing = "Amazing"
        case good = "Good"
        case neutral = "Neutral"
        case tired = "Tired"
        case terrible = "Terrible"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .amazing: return "😁"
            case .good: return "🙂"
            case .neutral: return "😐"
            case .tired: return "😴"
            case .terrible: return "😫"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.88, blue: 0.9),
                    Color(red: 0.7, green: 0.75, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Glass container
                    VStack(spacing: 25) {
                        Text("How do you feel?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Mood selection
                        HStack(spacing: 15) {
                            ForEach(Mood.allCases) { mood in
                                MoodButton(
                                    mood: mood,
                                    isSelected: selectedMood == mood,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedMood = mood
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Cold shower duration
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Cold Shower Duration")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            HStack {
                                Slider(value: $coldShowerDuration, in: 15...300, step: 15)
                                    .accentColor(.white)
                                
                                Text("\(Int(coldShowerDuration))s")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 50, alignment: .trailing)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Energy level
                        SliderView(
                            value: $energyLevel,
                            title: "Energy Level",
                            range: 1...10,
                            step: 1
                        )
                        
                        // Focus level
                        SliderView(
                            value: $focusLevel,
                            title: "Mental Focus",
                            range: 1...10,
                            step: 1
                        )
                        
                        // Recovery level
                        SliderView(
                            value: $recoveryLevel,
                            title: "Recovery",
                            range: 1...10,
                            step: 1
                        )
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        // Save button
                        Button(action: {
                            saveMoodData()
                            withAnimation {
                                showingSavedConfirmation = true
                            }
                            
                            // Hide confirmation after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showingSavedConfirmation = false
                                }
                            }
                        }) {
                            Text("Save")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.7),
                                            Color.blue.opacity(0.5)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.2))
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.6, green: 0.7, blue: 0.8).opacity(0.7),
                                                Color(red: 0.5, green: 0.6, blue: 0.7).opacity(0.7)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .blur(radius: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            
            // Saved confirmation overlay
            if showingSavedConfirmation {
                VStack {
                    Text("Saved!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green.opacity(0.8))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationTitle("Mood Tracker")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveMoodData() {
        // Here we would save the mood data to UserDefaults or a database
        // For MVP, we'll just print the values
        print("Mood: \(selectedMood?.rawValue ?? "Not selected")")
        print("Energy: \(Int(energyLevel))/10")
        print("Focus: \(Int(focusLevel))/10")
        print("Recovery: \(Int(recoveryLevel))/10")
        print("Duration: \(Int(coldShowerDuration)) seconds")
        print("Notes: \(notes)")
        
        // In a real implementation, we would save this data to UserDefaults or CoreData
        // and associate it with the current date
    }
}

struct MoodButton: View {
    let mood: MoodTrackerView.Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.icon)
                    .font(.system(size: 30))
                
                Text(mood.rawValue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        isSelected ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.7),
                                    Color.blue.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        isSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

struct SliderView: View {
    @Binding var value: Double
    let title: String
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            HStack {
                Slider(value: $value, in: range, step: step)
                    .accentColor(.white)
                
                Text("\(Int(value))/\(Int(range.upperBound))")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .padding(.horizontal)
    }
}

struct MoodTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoodTrackerView()
        }
    }
} 