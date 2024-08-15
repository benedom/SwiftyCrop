import XCTest
@testable import SwiftyCrop

final class SwiftyCropTests: XCTestCase {
    func testConfigurationInit() {
        let configuration = SwiftyCropConfiguration(
            maxMagnificationScale: 1.0,
            maskRadius: 1.0,
            cropImageCircular: true,
            rectAspectRatio: 4/3
        )
        
        XCTAssertEqual(configuration.maxMagnificationScale, 1.0)
        XCTAssertEqual(configuration.maskRadius, 1.0)
        XCTAssertEqual(configuration.cropImageCircular, true)
        XCTAssertEqual(configuration.rectAspectRatio, 4/3)
    }
}
