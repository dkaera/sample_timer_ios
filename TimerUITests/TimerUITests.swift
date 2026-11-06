import XCTest

final class TimerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSelectingModeUpdatesDuration() {
        let app = launchApp()

        app.buttons["ModeButton_focus"].tap()
        XCTAssertEqual(app.staticTexts["TimerText"].label, "Time remaining")
        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "25 minutes, 0 seconds")

        app.buttons["ModeButton_shortBreak"].tap()
        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "5 minutes, 0 seconds")

        app.buttons["ModeButton_longBreak"].tap()
        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "15 minutes, 0 seconds")
    }

    @MainActor
    func testStartAndPauseUpdatesTimerState() {
        let app = launchApp()

        app.buttons["ModeButton_shortBreak"].tap()
        app.buttons["StartPauseButton"].tap()
        XCTAssertEqual(app.buttons["StartPauseButton"].label, "Pause")

        let decremented = NSPredicate(format: "value != %@", "5 minutes, 0 seconds")
        expectation(for: decremented, evaluatedWith: app.staticTexts["TimerText"])
        waitForExpectations(timeout: 4)

        app.buttons["StartPauseButton"].tap()
        XCTAssertEqual(app.buttons["StartPauseButton"].label, "Start")
    }

    @MainActor
    func testResetRestoresSelectedModeDuration() {
        let app = launchApp()

        app.buttons["ModeButton_shortBreak"].tap()
        app.buttons["StartPauseButton"].tap()
        app.buttons["ResetButton"].tap()

        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "5 minutes, 0 seconds")
        XCTAssertEqual(app.buttons["StartPauseButton"].label, "Start")
    }

    @MainActor
    func testChangingModeStopsRunningTimer() {
        let app = launchApp()

        app.buttons["StartPauseButton"].tap()
        app.buttons["ModeButton_longBreak"].tap()

        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "15 minutes, 0 seconds")
        XCTAssertEqual(app.buttons["StartPauseButton"].label, "Start")
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        return app
    }
}
