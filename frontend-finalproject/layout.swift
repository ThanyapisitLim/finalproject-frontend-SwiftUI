//
//  MainLayout.swift
//  Frontend-finalProject
//
//  Created by tagter on 29/10/2568 BE.
//

import SwiftUI

struct MainLayout: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedTab) {
                    Home()
                        .tabItem {
                            Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                        }
                        .tag(0)
                    PollView()
                        .tabItem {
                            Label("Poll", systemImage: selectedTab == 1 ? "chart.bar.fill" : "chart.bar")
                        }
                        .tag(1)
                    Profile()
                        .tabItem {
                            Label("Profile", systemImage: selectedTab == 2 ? "person.crop.circle.fill" : "person.crop.circle")
                        }
                        .tag(2)
                }
                .tint(Color.indigo)
            }
            .navigationTitle(tabTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
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

