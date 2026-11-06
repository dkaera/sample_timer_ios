import XCTest
@testable import TimerCore

final class TimerEngineTests: XCTestCase {
    let start = Date(timeIntervalSince1970: 10000)

    func testInitialStateAndModeDurations() {
        let timer = TimerEngine()
        XCTAssertEqual(timer.mode, .focus)
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.formatted(at: start), "25:00")
        XCTAssertEqual(TimerMode.allCases.map(\.duration), [1500, 300, 900])
    }

    func testCountdownUsesElapsedTimeAndRoundsUp() {
        var timer = TimerEngine()
        timer.toggle(at: start)
        XCTAssertEqual(timer.remaining(at: start.addingTimeInterval(0.2)), 1500)
        XCTAssertEqual(timer.remaining(at: start.addingTimeInterval(1)), 1499)
        XCTAssertEqual(timer.formatted(at: start.addingTimeInterval(65)), "23:55")
    }

    func testPauseAndResumeExcludePausedTime() {
        var timer = TimerEngine()
        timer.toggle(at: start)
        timer.toggle(at: start.addingTimeInterval(10))
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.remaining(at: start.addingTimeInterval(100)), 1490)
        timer.toggle(at: start.addingTimeInterval(100))
        XCTAssertEqual(timer.remaining(at: start.addingTimeInterval(110)), 1480)
    }

    func testResetStopsAndRestoresCurrentMode() {
        var timer = TimerEngine()
        timer.select(.longBreak)
        timer.toggle(at: start)
        timer.reset()
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.remaining(at: start), 900)
    }

    func testSelectingModeStopsAndResetsEvenWhenReselecting() {
        var timer = TimerEngine()
        timer.toggle(at: start)
        timer.select(.shortBreak)
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.remaining(at: start), 300)
        timer.toggle(at: start)
        timer.select(.shortBreak)
        XCTAssertEqual(timer.remaining(at: start), 300)
        XCTAssertFalse(timer.isRunning)
    }

    func testCompletionAfterBackgroundGapHappensOnlyOnce() {
        var timer = TimerEngine()
        timer.select(.shortBreak)
        timer.toggle(at: start)
        XCTAssertFalse(timer.finishIfNeeded(at: start.addingTimeInterval(299)))
        XCTAssertTrue(timer.finishIfNeeded(at: start.addingTimeInterval(400)))
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.formatted(at: start), "00:00")
        XCTAssertFalse(timer.finishIfNeeded(at: start.addingTimeInterval(401)))
        timer.toggle(at: start.addingTimeInterval(402))
        XCTAssertFalse(timer.isRunning)
        timer.reset()
        timer.toggle(at: start.addingTimeInterval(403))
        XCTAssertTrue(timer.isRunning)
    }

    func testRunningStateSurvivesEncodingAndRestoresDeadline() throws {
        var timer = TimerEngine()
        timer.toggle(at: start)
        let restored = try JSONDecoder().decode(TimerEngine.self, from: JSONEncoder().encode(timer))
        XCTAssertTrue(restored.isRunning)
        XCTAssertEqual(restored.remaining(at: start.addingTimeInterval(100)), 1400)
    }
}
