import XCTest

final class UIScreenshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_homeScreen_savesScreenshot() {
        let app = XCUIApplication()
        app.launch()

        // Capture the initial screen (home)
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "01-Home"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

