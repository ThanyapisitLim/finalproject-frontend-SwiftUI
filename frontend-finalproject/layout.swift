import SwiftUI

struct MainLayout: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea() // background เดียวกับ Login/Register
                TabView(selection: $selectedTab) {
                    Home()
                        .tabItem {
                            Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                        }
                        .tag(0)
                    PollView()
                        .tabItem {
                            Label("My Poll", systemImage: selectedTab == 1 ? "chart.bar.fill" : "chart.bar")
                        }
                        .tag(1)
                    Result()
                        .tabItem {
                            Label("Result", systemImage: selectedTab == 2 ? "person.crop.circle.fill" : "person.crop.circle")
                        }
                        .tag(2)
                    Profile()
                        .tabItem {
                            Label("Profile", systemImage: selectedTab == 3 ? "person.crop.circle.fill" : "person.crop.circle")
                        }
                        .tag(3)
                }
                .tint(.indigo) // ปุ่ม / tab สีเดียวกับ Login/Register
            }
            .navigationTitle(tabTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(.indigo) // main tint ทั้ง navigationStack
    }

    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Home"
        case 1: return "My Polls"
        case 2: return "Profile"
        default: return ""
        }
    }
}

#Preview {
    MainLayout()
}
