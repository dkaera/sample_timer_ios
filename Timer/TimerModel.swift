import SwiftUI
import Combine
import AudioToolbox
import UserNotifications

@MainActor
final class TimerModel: ObservableObject {
    @Published private(set) var engine: TimerEngine
    @Published private(set) var now = Date()
    @Published var showsCompletion = false
    private var ticker: AnyCancellable?
    private var notificationTask: Task<Void, Never>?
    private var isActive = true
    private let requestsNotificationAuthorization: Bool
    private let storageKey = "timer.state.v1"
    private let notificationID = "timer.completion"

    init(resetStoredState: Bool = false, requestsNotificationAuthorization: Bool = true) {
        self.requestsNotificationAuthorization = requestsNotificationAuthorization
        if resetStoredState {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(TimerEngine.self, from: data) {
            engine = saved
        } else {
            engine = TimerEngine()
        }
        refresh(playSound: false)
        ticker = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect().sink { [weak self] _ in
                guard let self, self.isActive else { return }
                self.refresh()
            }
    }

    func toggle() {
        refresh()
        if !engine.isRunning && engine.remaining(at: now) == 0 { return }
        showsCompletion = false
        engine.toggle(at: now)
        save()
        cancelNotification()
        if engine.isRunning && requestsNotificationAuthorization {
            // Ask in context, after the user starts their first timer.
            Task {
                _ = try? await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound])
                if !isActive { scheduleNotification() }
            }
        }
    }

    func reset() {
        engine.reset()
        changed()
    }

    func select(_ mode: TimerMode) {
        engine.select(mode)
        changed()
    }

    func sceneChanged(_ phase: ScenePhase) {
        isActive = phase == .active
        if isActive {
            cancelNotification()
            // The scheduled notification handles sound while away.
            refresh(playSound: false)
        } else if phase == .background {
            scheduleNotification()
        }
    }

    private func changed() {
        now = Date()
        showsCompletion = false
        cancelNotification()
        save()
    }

    private func refresh(playSound: Bool = true) {
        now = Date()
        if engine.finishIfNeeded(at: now) {
            showsCompletion = true
            save()
            if playSound && isActive { AudioServicesPlayAlertSound(1007) }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(engine) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func cancelNotification() {
        notificationTask?.cancel()
        notificationTask = nil
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationID])
        center.removeDeliveredNotifications(withIdentifiers: [notificationID])
    }

    private func scheduleNotification() {
        cancelNotification()
        guard let deadline = engine.deadline else { return }
        let modeTitle = engine.mode.title
        notificationTask = Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            guard !Task.isCancelled, !isActive,
                  engine.deadline == deadline,
                  settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            else { return }
            let content = UNMutableNotificationContent()
            content.title = "Time's up!"
            content.body = "Your \(modeTitle.lowercased()) timer has finished."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: max(1, deadline.timeIntervalSinceNow), repeats: false)
            let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
            do {
                try await center.add(request)
                if Task.isCancelled {
                    center.removePendingNotificationRequests(withIdentifiers: [notificationID])
                }
            } catch {
                // The foreground countdown and sound work without notification permission.
            }
        }
    }
}
