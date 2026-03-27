import SwiftUI

@main
struct CalendarioApp: App {
    @State private var permissionManager = CalendarPermissionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(permissionManager)
        }
    }
}
