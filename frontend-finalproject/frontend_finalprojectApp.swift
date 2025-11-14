//
//  frontend_finalprojectApp.swift
//  frontend-finalproject
//
//  Created by tagter on 29/10/2568 BE.
//

import SwiftUI

@main
struct Frontend_finalprojectApp: App {
    @StateObject var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .onAppear {
                    authVM.checkLoginStatus()   // ⭐ โหลดค่า login ตอนเปิดแอป
                }
        }
    }
}




