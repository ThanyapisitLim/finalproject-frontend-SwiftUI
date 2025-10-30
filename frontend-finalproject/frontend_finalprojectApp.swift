//
//  frontend_finalprojectApp.swift
//  frontend-finalproject
//
//  Created by tagter on 29/10/2568 BE.
//

import SwiftUI

@main
struct Frontend_finalprojectApp: App {
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    LoadingView()
                } else {
                    MainLayout()
                        .transition(.opacity)
                }
            }
        }
    }
}
