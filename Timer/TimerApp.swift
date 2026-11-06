import SwiftUI

@main
struct TimerApp: App {
    @StateObject private var model = TimerModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            TimerScreen(model: model)
                .onChange(of: scenePhase) { _, phase in model.sceneChanged(phase) }
        }
    }
}
