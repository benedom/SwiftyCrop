import XCTest
import SwiftUI
@testable import SwiftyCrop

final class SwiftyCropTests: XCTestCase {
    func testConfigurationInit() {
        let configuration = SwiftyCropConfiguration(
            maxMagnificationScale: 1.0,
            maskRadius: 1.0,
            cropImageCircular: true,
            rectAspectRatio: 4/3,
            texts: SwiftyCropConfiguration.Texts(
                cancelButton: "Test 1",
                interactionInstructions: "Test 2",
                saveButton: "Test 3"
            ),
            fonts: SwiftyCropConfiguration.Fonts(
                cancelButton: Font.system(size: 12),
                interactionInstructions: Font.system(size: 13),
                saveButton: Font.system(size: 14)
            ),
            colors: SwiftyCropConfiguration.Colors(
                cancelButton: .red,
                interactionInstructions: .yellow,
                saveButton: .green,
                background: .gray
            )
        )
        
        XCTAssertEqual(configuration.maxMagnificationScale, 1.0)
        XCTAssertEqual(configuration.maskRadius, 1.0)
        XCTAssertEqual(configuration.cropImageCircular, true)
        XCTAssertEqual(configuration.rectAspectRatio, 4/3)
        
        XCTAssertEqual(configuration.texts.cancelButton, "Test 1")
        XCTAssertEqual(configuration.texts.interactionInstructions, "Test 2")
        XCTAssertEqual(configuration.texts.saveButton, "Test 3")
        
        XCTAssertEqual(configuration.fonts.cancelButton, Font.system(size: 12))
        XCTAssertEqual(configuration.fonts.interactionInstructions, Font.system(size: 13))
        XCTAssertEqual(configuration.fonts.saveButton, Font.system(size: 14))
        
        XCTAssertEqual(configuration.colors.cancelButton, Color.red)
        XCTAssertEqual(configuration.colors.interactionInstructions, Color.yellow)
        XCTAssertEqual(configuration.colors.saveButton, Color.green)
        XCTAssertEqual(configuration.colors.background, Color.gray)
    }
}
