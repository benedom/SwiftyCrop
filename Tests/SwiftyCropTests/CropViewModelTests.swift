import XCTest
import SwiftUI
@testable import SwiftyCrop

final class CropViewModelTests: XCTestCase {

    // MARK: - Mask Size Calculation

    func testCircleMaskSizeRadiusSmallerThanView() {
        let vm = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 200, height: 200))
        // diameter = min(50*2, min(200, 200)) = min(100, 200) = 100
        XCTAssertEqual(vm.maskSize, CGSize(width: 100, height: 100))
    }

    func testCircleMaskSizeRadiusLargerThanView() {
        let vm = CropViewModel(maskRadius: 200, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 100, height: 100))
        // diameter = min(200*2, min(100, 100)) = min(400, 100) = 100
        XCTAssertEqual(vm.maskSize, CGSize(width: 100, height: 100))
    }

    func testSquareMaskSizeMatchesCircle() {
        let vmCircle = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        let vmSquare = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .square, rectAspectRatio: 4/3)
        let size = CGSize(width: 200, height: 200)
        vmCircle.updateMaskDimensions(for: size)
        vmSquare.updateMaskDimensions(for: size)
        XCTAssertEqual(vmSquare.maskSize, vmCircle.maskSize)
    }

    func testRectangleMaskSizeWidthConstrained() {
        // view (200, 300), maskRadius=200
        // maxWidth = min(200, 400) = 200, maxHeight = min(300, 400) = 300
        // 200/300 = 0.667 < 4/3 = 1.333 → else branch
        // maskSize = (maxWidth, maxWidth / rectAspectRatio) = (200, 150)
        let vm = CropViewModel(maskRadius: 200, maxMagnificationScale: 4, maskShape: .rectangle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 200, height: 300))
        XCTAssertEqual(vm.maskSize.width, 200, accuracy: 0.001)
        XCTAssertEqual(vm.maskSize.height, 150, accuracy: 0.001)
    }

    func testRectangleMaskSizeHeightConstrained() {
        // view (400, 200), maskRadius=200
        // maxWidth = min(400, 400) = 400, maxHeight = min(200, 400) = 200
        // 400/200 = 2 > 4/3 = 1.333 → if branch
        // maskSize = (maxHeight * rectAspectRatio, maxHeight) = (200*4/3, 200)
        let vm = CropViewModel(maskRadius: 200, maxMagnificationScale: 4, maskShape: .rectangle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 400, height: 200))
        XCTAssertEqual(vm.maskSize.width, 200 * 4/3, accuracy: 0.001)
        XCTAssertEqual(vm.maskSize.height, 200, accuracy: 0.001)
    }

    func testRectangleMaskAspectRatioPreserved() {
        let vm = CropViewModel(maskRadius: 200, maxMagnificationScale: 4, maskShape: .rectangle, rectAspectRatio: 16/9)
        vm.updateMaskDimensions(for: CGSize(width: 400, height: 300))
        let ratio = vm.maskSize.width / vm.maskSize.height
        XCTAssertEqual(ratio, 16/9, accuracy: 0.001)
    }

    // MARK: - Drag Gesture Max

    func testDragGestureMaxNormalCase() {
        let vm = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 200, height: 200))
        // maskSize = (100, 100), scale = 1, imageSizeInView = (200, 200)
        // xLimit = max(0, (200/2 * 1) - 100/2) = max(0, 100 - 50) = 50
        let dragMax = vm.calculateDragGestureMax()
        XCTAssertEqual(dragMax.x, 50, accuracy: 0.001)
        XCTAssertEqual(dragMax.y, 50, accuracy: 0.001)
    }

    func testDragGestureMaxClampsToZeroWhenImageSmallerThanMask() {
        // mask fills entire view → no room to drag
        let vm = CropViewModel(maskRadius: 200, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 100, height: 100))
        // maskSize = (100, 100), imageSizeInView = (100, 100)
        // xLimit = max(0, (100/2 * 1) - 100/2) = max(0, 0) = 0
        let dragMax = vm.calculateDragGestureMax()
        XCTAssertEqual(dragMax.x, 0, accuracy: 0.001)
        XCTAssertEqual(dragMax.y, 0, accuracy: 0.001)
    }

    func testDragGestureMaxScaledUp() {
        let vm = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 200, height: 200))
        vm.scale = 2
        // xLimit = max(0, (200/2 * 2) - 100/2) = max(0, 200 - 50) = 150
        let dragMax = vm.calculateDragGestureMax()
        XCTAssertEqual(dragMax.x, 150, accuracy: 0.001)
        XCTAssertEqual(dragMax.y, 150, accuracy: 0.001)
    }

    // MARK: - Magnification Limits

    func testMagnificationLimitsSymmetricMask() {
        let vm = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 200, height: 200))
        // maskSize = (100, 100), imageSizeInView = (200, 200)
        // minScale = max(100/200, 100/200) = 0.5
        let (minScale, maxScale) = vm.calculateMagnificationGestureMaxValues()
        XCTAssertEqual(minScale, 0.5, accuracy: 0.001)
        XCTAssertEqual(maxScale, 4.0, accuracy: 0.001)
    }

    func testMagnificationLimitsMaxScaleRespected() {
        let vm = CropViewModel(maskRadius: 50, maxMagnificationScale: 10, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 200, height: 200))
        let (_, maxScale) = vm.calculateMagnificationGestureMaxValues()
        XCTAssertEqual(maxScale, 10.0, accuracy: 0.001)
    }

    func testMagnificationMinScaleIsAtLeastMaskToImageRatio() {
        // Asymmetric: wider mask relative to image width
        let vm = CropViewModel(maskRadius: 200, maxMagnificationScale: 4, maskShape: .rectangle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 300, height: 400))
        let (minScale, _) = vm.calculateMagnificationGestureMaxValues()
        let expectedMin = max(vm.maskSize.width / 300, vm.maskSize.height / 400)
        XCTAssertEqual(minScale, expectedMin, accuracy: 0.001)
    }

    // MARK: - Image Cropping & Rotation (UIKit only)

    #if canImport(UIKit)

    private func makeSolidImage(size: CGSize = CGSize(width: 100, height: 100), color: UIColor = .red) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    func testCropToRectangleProducesNonNilResult() {
        let vm = CropViewModel(maskRadius: 40, maxMagnificationScale: 4, maskShape: .rectangle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 100, height: 100))
        let result = vm.cropToRectangle(makeSolidImage())
        XCTAssertNotNil(result)
    }

    func testCropToRectangleOutputDimensions() {
        // maskRadius=40, view=(100,100), rectAspectRatio=4/3
        // maxWidth=min(100,80)=80, maxHeight=min(100,80)=80
        // 80/80=1 < 4/3 → else branch → maskSize=(80, 60)
        // factor=1, cropSize=(80,60), output=(80,60)
        let vm = CropViewModel(maskRadius: 40, maxMagnificationScale: 4, maskShape: .rectangle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 100, height: 100))
        guard let result = vm.cropToRectangle(makeSolidImage()) else {
            XCTFail("cropToRectangle returned nil")
            return
        }
        XCTAssertEqual(result.size.width, 80, accuracy: 1)
        XCTAssertEqual(result.size.height, 60, accuracy: 1)
    }

    func testCropToSquareProducesNonNilResult() {
        let vm = CropViewModel(maskRadius: 40, maxMagnificationScale: 4, maskShape: .square, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 100, height: 100))
        let result = vm.cropToSquare(makeSolidImage())
        XCTAssertNotNil(result)
    }

    func testCropToSquareOutputIsSquare() {
        // diameter = min(80, 100) = 80 → maskSize=(80,80) → output=(80,80)
        let vm = CropViewModel(maskRadius: 40, maxMagnificationScale: 4, maskShape: .square, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 100, height: 100))
        guard let result = vm.cropToSquare(makeSolidImage()) else {
            XCTFail("cropToSquare returned nil")
            return
        }
        XCTAssertEqual(result.size.width, result.size.height)
    }

    func testCropToCircleProducesNonNilResult() {
        let vm = CropViewModel(maskRadius: 40, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 100, height: 100))
        let result = vm.cropToCircle(makeSolidImage())
        XCTAssertNotNil(result)
    }

    func testCropToCircleOutputIsSquareBoundingBox() {
        let vm = CropViewModel(maskRadius: 40, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        vm.updateMaskDimensions(for: CGSize(width: 100, height: 100))
        guard let result = vm.cropToCircle(makeSolidImage()) else {
            XCTFail("cropToCircle returned nil")
            return
        }
        XCTAssertEqual(result.size.width, result.size.height)
    }

    // MARK: - Rotation

    func testRotateByZeroDegreesReturnsNonNil() {
        let vm = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        let result = vm.rotate(makeSolidImage(), Angle(degrees: 0))
        XCTAssertNotNil(result)
    }

    func testRotateBy90DegreesReturnsNonNil() {
        let vm = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        let result = vm.rotate(makeSolidImage(), Angle(degrees: 90))
        XCTAssertNotNil(result)
    }

    func testRotateBy180DegreesReturnsNonNil() {
        let vm = CropViewModel(maskRadius: 50, maxMagnificationScale: 4, maskShape: .circle, rectAspectRatio: 4/3)
        let result = vm.rotate(makeSolidImage(), Angle(degrees: 180))
        XCTAssertNotNil(result)
    }

    // MARK: - correctlyOriented

    func testCorrectlyOrientedUpImageReturnsNonNil() {
        // UIGraphicsImageRenderer produces .up images
        let image = makeSolidImage()
        XCTAssertEqual(image.imageOrientation, .up)
        XCTAssertNotNil(image.correctlyOriented)
    }

    func testCorrectlyOrientedNonUpImageReturnsNonNil() {
        let image = makeSolidImage()
        guard let cgImage = image.cgImage else {
            XCTFail("Could not get cgImage")
            return
        }
        let rotated = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
        XCTAssertEqual(rotated.imageOrientation, .right)
        XCTAssertNotNil(rotated.correctlyOriented)
    }

    func testCorrectlyOrientedUpImageReturnsSelf() {
        let image = makeSolidImage()
        // .up images are returned as-is (same pixel content)
        let oriented = image.correctlyOriented
        XCTAssertNotNil(oriented)
        XCTAssertEqual(oriented?.size, image.size)
    }

    #endif
}
