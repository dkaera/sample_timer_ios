import SwiftUI

@main
struct TimerApp: App {
    @StateObject private var model: TimerModel
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
        _model = StateObject(wrappedValue: TimerModel(
            resetStoredState: isUITesting,
            requestsNotificationAuthorization: !isUITesting
        ))
    }

    var body: some Scene {
        WindowGroup {
            TimerScreen(model: model)
                .onChange(of: scenePhase) { _, phase in model.sceneChanged(phase) }
        }
    }
}
