import SwiftUI

/// `SwiftyCropView` is a SwiftUI view for cropping images.
///
/// You can customize the cropping behavior using a `SwiftyCropConfiguration` instance and a completion handler.
///
/// - Parameters:
///   - imageToCrop: The image to be cropped.
///   - maskShape: The shape of the mask used for cropping.
///   - configuration: The configuration for the cropping behavior. If nothing is specified, the default is used.
///   - onComplete: A closure that's called when the cropping is complete. This closure returns the cropped `UIImage?`. If an error occurs the return value is nil.
struct SwiftyCropView: View {
    let imageToCrop: UIImage
    let maskShape: MaskShape
    let configuration: SwiftyCropConfiguration = SwiftyCropConfiguration()
    let onComplete: (UIImage?) -> Void
    
    var body: some View {
        CropView(
            image: imageToCrop,
            maskShape: maskShape,
            configuration: configuration,
            onComplete: onComplete
        )
    }
}
