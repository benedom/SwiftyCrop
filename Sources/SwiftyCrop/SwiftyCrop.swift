import SwiftUI

/// `SwiftyCropView` is a SwiftUI view for cropping images.
///
/// You can customize the cropping behavior using a `SwiftyCropConfiguration` instance and a completion handler.
///
/// - Parameters:
///   - imageToCrop: The image to be cropped. Can be passed as a `UIImage` or a `Binding<UIImage?>`.
///     Using a `Binding` is recommended when presenting inside `fullScreenCover(isPresented:)` to ensure
///     the view always accesses the current image value.
///   - maskShape: The shape of the mask used for cropping.
///   - configuration: The configuration for the cropping behavior. If nothing is specified, the default is used.
///   - onCancel: An optional closure that's called when the cropping is cancelled.
///   - onComplete: A closure that's called when the cropping is complete. This closure returns the cropped `UIImage?`.
///     If an error occurs the return value is nil.
public struct SwiftyCropView: View {
    @Binding private var imageToCropBinding: UIImage?
    private let imageToCropDirect: UIImage?
    private let usesBinding: Bool
    private let maskShape: MaskShape
    private let configuration: SwiftyCropConfiguration
    private let onCancel: (() -> Void)?
    private let onComplete: (UIImage?) -> Void

    /// Creates a new `SwiftyCropView` with a direct image.
    ///
    /// - Parameters:
    ///   - imageToCrop: The image to be cropped.
    ///   - maskShape: The shape of the mask used for cropping.
    ///   - configuration: The configuration for the cropping behavior.
    ///   - onCancel: An optional closure called when cropping is cancelled.
    ///   - onComplete: A closure called when cropping is complete.
    public init(
        imageToCrop: UIImage,
        maskShape: MaskShape,
        configuration: SwiftyCropConfiguration = SwiftyCropConfiguration(),
        onCancel: (() -> Void)? = nil,
        onComplete: @escaping (UIImage?) -> Void
    ) {
        self._imageToCropBinding = .constant(nil)
        self.imageToCropDirect = imageToCrop
        self.usesBinding = false
        self.maskShape = maskShape
        self.configuration = configuration
        self.onCancel = onCancel
        self.onComplete = onComplete
    }

    /// Creates a new `SwiftyCropView` with a binding to an optional image.
    ///
    /// This initializer is recommended when using `SwiftyCropView` inside a `fullScreenCover(isPresented:)`
    /// modifier, as it ensures the view always reads the current image value rather than a captured snapshot.
    ///
    /// - Parameters:
    ///   - imageToCrop: A binding to the optional image to be cropped.
    ///   - maskShape: The shape of the mask used for cropping.
    ///   - configuration: The configuration for the cropping behavior.
    ///   - onCancel: An optional closure called when cropping is cancelled.
    ///   - onComplete: A closure called when cropping is complete.
    public init(
        imageToCrop: Binding<UIImage?>,
        maskShape: MaskShape,
        configuration: SwiftyCropConfiguration = SwiftyCropConfiguration(),
        onCancel: (() -> Void)? = nil,
        onComplete: @escaping (UIImage?) -> Void
    ) {
        self._imageToCropBinding = imageToCrop
        self.imageToCropDirect = nil
        self.usesBinding = true
        self.maskShape = maskShape
        self.configuration = configuration
        self.onCancel = onCancel
        self.onComplete = onComplete
    }

    private var currentImage: UIImage? {
        usesBinding ? imageToCropBinding : imageToCropDirect
    }

    public var body: some View {
        Group {
            if let image = currentImage {
                CropView(
                    image: image,
                    maskShape: maskShape,
                    configuration: configuration,
                    onCancel: onCancel,
                    onComplete: onComplete
                )
            } else {
                // When image is nil (e.g., during initial fullScreenCover presentation),
                // show an empty view with background. The view will update when binding changes.
                Color.clear
                    .background(configuration.colors.background)
            }
        }
    }
}
