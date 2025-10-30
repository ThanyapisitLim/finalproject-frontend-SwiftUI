//
//  MainLayout.swift
//  Frontend-finalProject
//
//  Created by tagter on 29/10/2568 BE.
//


import SwiftUI

struct MainLayout: View {
    var body: some View {
        NavigationStack {
            TabView {
                Home()
                    .tabItem {
                        Label("Vote", systemImage: "house")
                    }

                Poll()
                    .tabItem {
                        Label("Poll", systemImage: "paperplane")
                    }
                Profile()
                    .tabItem {
                        Label("Profilee", systemImage: "person.circle")
                    }
                //hello
            }
            .navigationTitle(getTitle()) // ใช้ฟังก์ชันตั้งชื่อหน้าปัจจุบัน
            
        }
    }

    // ฟังก์ชันเพื่อเปลี่ยนชื่อ navigation title ตามแท็บ
    private func getTitle() -> String {
        return "Main App"
    }
}

#Preview {
    MainLayout()
}
