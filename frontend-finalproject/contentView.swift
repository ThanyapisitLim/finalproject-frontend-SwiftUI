import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                MainLayout()
                    .environmentObject(authVM)
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
        .tint(.indigo) // ใช้สีเดียวกับ Login/Register
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}
