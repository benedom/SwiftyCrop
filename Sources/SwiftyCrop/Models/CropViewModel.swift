import SwiftUI
import UIKit

class CropViewModel: ObservableObject {
    private let maxMagnificationScale: CGFloat
    var imageSizeInView: CGSize = .zero
    var maskRadius: CGFloat

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
    func cropToSquare(_ image: UIImage) -> UIImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }

        let cropRect = calculateCropRect(orientedImage)

        guard let cgImage = orientedImage.cgImage,
              let result = cgImage.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: result)
    }

    /**
     Crops the image to the part that is dragged/zoomed inside the view. Cropped image will be a circle.
     - Parameters:
        - image: The UIImage to crop
     - Returns: A cropped UIImage if the cropping operation is successful; otherwise nil.
     */
    func cropToCircle(_ image: UIImage) -> UIImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }

        let cropRect = calculateCropRect(orientedImage)

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
    }

    /**
     Calculates the rectangle to crop.
     - Parameters:
        - image: The UIImage to calculate the rectangle to crop for
     - Returns: A CGRect representing the rectangle to crop.
     */
    private func calculateCropRect(_ orientedImage: UIImage) -> CGRect {
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

private extension UIImage {
    /**
     A UIImage instance with corrected orientation.
     If the instance's orientation is already `.up`, it simply returns the original.
     - Returns: An optional UIImage that represents the correctly oriented image.
     */
    var correctlyOriented: UIImage? {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
