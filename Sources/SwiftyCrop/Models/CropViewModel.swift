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
    @Published var circleSize: CGSize = .zero
    
    init(
        maskRadius: CGFloat,
        maxMagnificationScale: CGFloat
    ) {
        self.maskRadius = maskRadius
        self.maxMagnificationScale = maxMagnificationScale
    }
    
    /**
     Calculates the max points that the image can be dragged to.
     */
    func calculateDragGestureMax() -> CGPoint {
        let yLimit = ((imageSizeInView.height / 2) * scale) - maskRadius
        let xLimit = ((imageSizeInView.width / 2) * scale) - maskRadius
        return CGPoint(x: xLimit, y: yLimit)
    }
    
    /**
     Calculates the maximum magnification values that are applied when zooming the image, so that the image can not be zoomed out of its own size.
     */
    func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        let minScale = (maskRadius * 2) / min(imageSizeInView.width, imageSizeInView.height)
        return (minScale, maxMagnificationScale)
    }
    
    /**
     Crops the image to the part that is dragged/zoomed inside the view. Cropped image will **always** be a square, no matter what mask shape is used.
     */
    func crop(_ image: UIImage) -> UIImage? {
        guard let orientedImage = image.correctlyOriented else {
            return nil
        }
        let factor = min((orientedImage.size.width / imageSizeInView.width), (orientedImage.size.height / imageSizeInView.height)) /// The relation factor of the originals image width/height and the width/height of the image displayed in the view (initial)
        let centerInOriginalImage = CGPoint(x: orientedImage.size.width / 2, y: orientedImage.size.height / 2)
        let cropRadiusInOriginalImage = (maskRadius * factor) / scale /// Calculate the crop radius inside the original image which based on the mask radius
        let offsetX = offset.width * factor /// The x offset the image has by dragging
        let offsetY = offset.height * factor /// The y offset the image has by dragging
        let cropRectX = (centerInOriginalImage.x - cropRadiusInOriginalImage) - (offsetX / scale) /// Calculates the x coordinate of the crop rectangle inside the original image
        let cropRectY = (centerInOriginalImage.y - cropRadiusInOriginalImage) - (offsetY / scale) /// Calculates the y coordinate of the crop rectangle inside the original image
        let cropRectCoordinate = CGPoint(x: cropRectX, y: cropRectY)
        let cropRectDimension = cropRadiusInOriginalImage * 2 /// Cropped rects dimension is twice its radius (diameter), since it's always a square it's used both for width and height
        
        let cropRect = CGRect(
            x: cropRectCoordinate.x,
            y: cropRectCoordinate.y,
            width: cropRectDimension,
            height: cropRectDimension
        )
        
        guard let cgImage = orientedImage.cgImage,
              let result = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: result)
    }
}

private extension UIImage {
    var correctlyOriented: UIImage? {
        if imageOrientation == .up { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}
