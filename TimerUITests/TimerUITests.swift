import XCTest

final class TimerUITests: XCTestCase {
    @MainActor
    func testModesStartPauseAndReset() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["ModeButton_focus"].tap()
        XCTAssertEqual(app.staticTexts["TimerText"].label, "Time remaining")
        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "25 minutes, 0 seconds")
        app.buttons["ModeButton_shortBreak"].tap()
        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "5 minutes, 0 seconds")
        app.buttons["StartPauseButton"].tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let deny = springboard.alerts.buttons["Don’t Allow"]
        if deny.waitForExistence(timeout: 2) { deny.tap() }
        XCTAssertEqual(app.buttons["StartPauseButton"].label, "Pause")
        let decremented = NSPredicate(format: "value != %@", "5 minutes, 0 seconds")
        expectation(for: decremented, evaluatedWith: app.staticTexts["TimerText"])
        waitForExpectations(timeout: 4)
        app.buttons["StartPauseButton"].tap()
        XCTAssertEqual(app.buttons["StartPauseButton"].label, "Start")
        app.buttons["ResetButton"].tap()
        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "5 minutes, 0 seconds")
        app.buttons["StartPauseButton"].tap()
        app.buttons["ModeButton_longBreak"].tap()
        XCTAssertEqual(app.staticTexts["TimerText"].value as? String, "15 minutes, 0 seconds")
        XCTAssertEqual(app.buttons["StartPauseButton"].label, "Start")
        app.buttons["ModeButton_focus"].tap()
    }
}
