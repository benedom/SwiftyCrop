import XCTest
@testable import SwiftyCrop

final class SwiftyCropTests: XCTestCase {
    func testConfigurationInit() {
        let configuration = SwiftyCropConfiguration(
            maxMagnificationScale: 1.0,
            maskRadius: 1.0,
            cropImageCircular: true,
            rectAspectRatio: 4/3,
            customTexts: SwiftyCropConfiguration.Texts(
                cancelButtonText: "Test 1",
                interactionInstructionsText: "Test 2",
                saveButtonText: "Test 3"
            )
        )
        
        XCTAssertEqual(configuration.maxMagnificationScale, 1.0)
        XCTAssertEqual(configuration.maskRadius, 1.0)
        XCTAssertEqual(configuration.cropImageCircular, true)
        XCTAssertEqual(configuration.rectAspectRatio, 4/3)
        XCTAssertEqual(configuration.customTexts?.cancelButtonText, "Test 1")
        XCTAssertEqual(configuration.customTexts?.interactionInstructionsText, "Test 2")
        XCTAssertEqual(configuration.customTexts?.saveButtonText, "Test 3")
    }
}
