import SwiftUI

struct Guard: View {
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
        .tint(.indigo)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}
