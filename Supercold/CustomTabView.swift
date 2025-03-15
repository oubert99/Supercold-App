import SwiftUI

struct CustomTabView: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabButton(
                    isSelected: selectedTab == index,
                    item: tabs[index],
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }
                )
            }
        }
        .padding(8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.15))
                .background(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .blur(radius: 0.5)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabButton: View {
    let isSelected: Bool
    let item: TabItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                
                if isSelected {
                    Text(item.title)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, isSelected ? 16 : 12)
            .background(
                Capsule()
                    .fill(isSelected ? 
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
                                Color.clear,
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
            )
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .contentShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabItem {
    let title: String
    let icon: String
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView(selectedTab: .constant(0), tabs: [
            TabItem(title: "Calendar", icon: "calendar"),
            TabItem(title: "Shower", icon: "drop.fill"),
            TabItem(title: "Mood", icon: "face.smiling")
        ])
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray)
    }
} 