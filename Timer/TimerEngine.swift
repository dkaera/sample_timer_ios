import Foundation

enum TimerMode: String, CaseIterable, Codable, Identifiable {
    case focus, shortBreak, longBreak
    var id: String { rawValue }
    var title: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
    var duration: Int {
        switch self {
        case .focus: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }
}

/// A deadline keeps elapsed time accurate even when iOS suspends the app.
struct TimerEngine: Codable {
    private(set) var mode: TimerMode = .focus
    private(set) var pausedSeconds = TimerMode.focus.duration
    private(set) var deadline: Date?
    var isRunning: Bool { deadline != nil }

    func remaining(at now: Date) -> Int {
        guard let deadline else { return pausedSeconds }
        return min(mode.duration, max(0, Int(ceil(deadline.timeIntervalSince(now)))))
    }

    mutating func toggle(at now: Date) {
        if isRunning {
            pausedSeconds = remaining(at: now)
            deadline = nil
        } else if pausedSeconds > 0 {
            deadline = now.addingTimeInterval(TimeInterval(pausedSeconds))
        }
    }

    mutating func reset() {
        deadline = nil
        pausedSeconds = mode.duration
    }

    mutating func select(_ mode: TimerMode) {
        self.mode = mode
        reset()
    }

    /// Returns true once, only when a running timer reaches its deadline.
    @discardableResult
    mutating func finishIfNeeded(at now: Date) -> Bool {
        guard isRunning, remaining(at: now) == 0 else { return false }
        deadline = nil
        pausedSeconds = 0
        return true
    }

    func formatted(at now: Date) -> String {
        let seconds = remaining(at: now)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
