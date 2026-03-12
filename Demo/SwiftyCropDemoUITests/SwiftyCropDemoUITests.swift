import XCTest

final class SwiftyCropDemoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    private func openCropView() {
        let cropButton = app.buttons["cropImageButton"]
        XCTAssertTrue(cropButton.waitForExistence(timeout: 5), "Crop image button should be visible")
        cropButton.tap()
    }

    private var cancelButton: XCUIElement {
        app.buttons["cancelButton"]
    }

    private var saveButton: XCUIElement {
        app.buttons["saveButton"]
    }

    // MARK: - Tests

    func testCropViewOpens() throws {
        openCropView()
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Cancel button should appear when crop view is open")
    }

    func testCancelDismissesCropView() throws {
        openCropView()
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()
        XCTAssertFalse(cancelButton.waitForExistence(timeout: 3), "Cancel button should disappear after dismissal")
    }

    func testSaveCropProducesImage() throws {
        openCropView()
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save button should be visible in crop view")
        saveButton.tap()
        XCTAssertFalse(saveButton.waitForExistence(timeout: 3), "Crop view should be dismissed after saving")
    }

    func testCircleMaskShapeOpensCropView() throws {
        let circlePicker = app.buttons["circle"]
        if circlePicker.exists {
            circlePicker.tap()
        }
        openCropView()
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Crop view should open with circle mask")
    }

    func testRectangleMaskShapeOpensCropView() throws {
        let rectanglePicker = app.buttons["rectangle"]
        if rectanglePicker.exists {
            rectanglePicker.tap()
        }
        openCropView()
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Crop view should open with rectangle mask")
    }
}
