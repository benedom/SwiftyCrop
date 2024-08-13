import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
typealias PlatformImage = NSImage
#endif

class CropViewModel: ObservableObject {
    private let maxMagnificationScale: CGFloat
    var imageSizeInView: CGSize = .zero {
        didSet {
            maskRadius = min(maskRadius, min(imageSizeInView.width, imageSizeInView.height) / 2)
        }
    }
    @Published var maskRadius: CGFloat

    @Published var scale: CGFloat = 1.0
    @Published var lastScale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero
    @Published var angle: Angle = Angle(degrees: 0)
    @Published var lastAngle: Angle = Angle(degrees: 0)

    init(
        maskRadius: CGFloat,
        maxMagnificationScale: CGFloat
    ) {
        self.maskRadius = maskRadius
        self.maxMagnificationScale = maxMagnificationScale
    }

    /**
     Calculates the max points that the image can be dragged to.
     - Returns: A CGPoint representing the maximum points to which the image can be dragged.
     */
    func calculateDragGestureMax() -> CGPoint {
        let yLimit = ((imageSizeInView.height / 2) * scale) - maskRadius
        let xLimit = ((imageSizeInView.width / 2) * scale) - maskRadius
        return CGPoint(x: xLimit, y: yLimit)
    }

    /**
     Calculates the maximum magnification values that are applied when zooming the image,
     so that the image can not be zoomed out of its own size.
     - Returns: A tuple (CGFloat, CGFloat) representing the minimum and maximum magnification scale values.
       The first value is the minimum scale at which the image can be displayed without being smaller than its own size.
       The second value is the preset maximum magnification scale.
     */
    func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        let minScale = (maskRadius * 2) / min(imageSizeInView.width, imageSizeInView.height)
        return (minScale, maxMagnificationScale)
    }

    /**
     Crops the image to the part that is dragged/zoomed inside the view. Cropped image will be a square.
     - Parameters:
        - image: The UIImage to crop
     - Returns: A cropped UIImage if the cropping operation is successful; otherwise nil.
     */
    func cropToSquare(_ image: PlatformImage) -> PlatformImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }

        let cropRect = calculateCropRect(orientedImage)

        #if canImport(UIKit)
        guard let cgImage = orientedImage.cgImage,
              let result = cgImage.cropping(to: cropRect) else {
            return nil
        }
        return UIImage(cgImage: result)
        #elseif canImport(AppKit)
        guard let cgImage = orientedImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }
        return NSImage(cgImage: croppedCGImage, size: cropRect.size)
        #endif
    }

    /**
     Crops the image to the part that is dragged/zoomed inside the view. Cropped image will be a circle.
     - Parameters:
        - image: The UIImage to crop
     - Returns: A cropped UIImage if the cropping operation is successful; otherwise nil.
     */
    func cropToCircle(_ image: PlatformImage) -> PlatformImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }

        let cropRect = calculateCropRect(orientedImage)
        
        #if canImport(UIKit)
        // A circular crop results in some transparency in the
        // cropped image, so set opaque to false to ensure the
        // cropped image does not include a background fill
        let imageRendererFormat = orientedImage.imageRendererFormat
        imageRendererFormat.opaque = false

        // UIGraphicsImageRenderer().image provides a block
        // interface to draw into in a new UIImage
        let circleCroppedImage = UIGraphicsImageRenderer(
            // The cropRect.size is the size of
            // the resulting circleCroppedImage
            size: cropRect.size,
            format: imageRendererFormat).image { _ in

            // The drawRect is the cropRect starting at (0,0)
            let drawRect = CGRect(
                origin: .zero,
                size: cropRect.size
            )

            // addClip on a UIBezierPath will clip all contents
            // outside of the UIBezierPath drawn after addClip
            // is called, in this case, drawRect is a circle so
            // the UIBezierPath clips drawing to the circle
            UIBezierPath(ovalIn: drawRect).addClip()

            // The drawImageRect is offsets the image’s bounds
            // such that the circular clip is at the center of
            // the image
            let drawImageRect = CGRect(
                origin: CGPoint(
                    x: -cropRect.origin.x,
                    y: -cropRect.origin.y
                ),
                size: orientedImage.size
            )

            // Draws the orientedImage inside of the
            // circular clip
            orientedImage.draw(in: drawImageRect)
        }

        return circleCroppedImage
        #elseif canImport(AppKit)
        let circleCroppedImage = NSImage(size: cropRect.size)
        circleCroppedImage.lockFocus()
        let drawRect = NSRect(origin: .zero, size: cropRect.size)
        NSBezierPath(ovalIn: drawRect).addClip()
        let drawImageRect = NSRect(
            origin: NSPoint(x: -cropRect.origin.x, y: -cropRect.origin.y),
            size: orientedImage.size
        )
        orientedImage.draw(in: drawImageRect)
        circleCroppedImage.unlockFocus()
        return circleCroppedImage
        #endif


    }

    /**
     Rotates the image to the angle that is rotated inside the view.
     - Parameters:
        - image: The UIImage to rotate
        - angle: The Angle to rotate to
     - Returns: A rotated UIImage if the rotating operation is successful; otherwise nil.
     */
    func rotate(_ image: PlatformImage, _ angle: Angle) -> PlatformImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }

        #if canImport(UIKit)
        guard let cgImage = orientedImage.cgImage else {
            return nil
        }
        #elseif canImport(AppKit)
        guard let cgImage = orientedImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        #endif

        let ciImage = CIImage(cgImage: cgImage)

        // Prepare filter
        guard let filter = CIFilter.straightenFilter(image: ciImage, radians: angle.radians),
            // Get output image
            let output = filter.outputImage else {
                return nil
            }

        // Create resulting image
        let context = CIContext()
        guard let result = context.createCGImage(output, from: output.extent) else {
            return nil
        }

        #if canImport(UIKit)
        return UIImage(cgImage: result)
        #elseif canImport(AppKit)
        return NSImage(cgImage: result, size: NSSize(width: result.width, height: result.height))
        #endif
        }

    /**
     Calculates the rectangle to crop.
     - Parameters:
        - image: The UIImage to calculate the rectangle to crop for
     - Returns: A CGRect representing the rectangle to crop.
     */
    private func calculateCropRect(_ orientedImage: PlatformImage) -> CGRect {
        // The relation factor of the originals image width/height
        // and the width/height of the image displayed in the view (initial)
        let factor = min(
            (orientedImage.size.width / imageSizeInView.width), (orientedImage.size.height / imageSizeInView.height)
        )
        let centerInOriginalImage = CGPoint(x: orientedImage.size.width / 2, y: orientedImage.size.height / 2)
        // Calculate the crop radius inside the original image which based on the mask radius
        let cropRadiusInOriginalImage = (maskRadius * factor) / scale
        // The x offset the image has by dragging
        let offsetX = offset.width * factor
        // The y offset the image has by dragging
        let offsetY = offset.height * factor
        // Calculates the x coordinate of the crop rectangle inside the original image
        let cropRectX = (centerInOriginalImage.x - cropRadiusInOriginalImage) - (offsetX / scale)
        // Calculates the y coordinate of the crop rectangle inside the original image
        let cropRectY = (centerInOriginalImage.y - cropRadiusInOriginalImage) - (offsetY / scale)
        let cropRectCoordinate = CGPoint(x: cropRectX, y: cropRectY)
        // Cropped rects dimension is twice its radius (diameter),
        // since it's always a square it's used both for width and height
        let cropRectDimension = cropRadiusInOriginalImage * 2

        let cropRect = CGRect(
            x: cropRectCoordinate.x,
            y: cropRectCoordinate.y,
            width: cropRectDimension,
            height: cropRectDimension
        )

        return cropRect
    }
}

extension PlatformImage {
    /**
     For iOS, A UIImage instance with corrected orientation.
     If the instance's orientation is already `.up`, it simply returns the original.
     - Returns: An optional UIImage that represents the correctly oriented image.
     */
    var correctlyOriented: PlatformImage? {
        #if canImport(UIKit)
        if imageOrientation == .up { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
        #elseif canImport(AppKit)
        return self
        #endif
    }
}

private extension CIFilter {
    /**
     Creates the straighten filter.
     - Parameters:
        - inputImage: The CIImage to use as an input image
        - radians: An angle in radians
     - Returns: A generated CIFilter.
     */
    static func straightenFilter(image: CIImage, radians: Double) -> CIFilter? {
        let angle: Double = radians != 0 ? -radians : 0
        guard let filter = CIFilter(name: "CIStraightenFilter") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(angle, forKey: kCIInputAngleKey)
        return filter
    }
}
