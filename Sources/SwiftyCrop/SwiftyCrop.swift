import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// `SwiftyCropView` is a SwiftUI view for cropping images.
///
/// You can customize the cropping behavior using a `SwiftyCropConfiguration` instance and a completion handler.
///
/// - Parameters:
///   - imageToCrop: The image to be cropped.
///   - maskShape: The shape of the mask used for cropping.
///   - configuration: The configuration for the cropping behavior. If nothing is specified, the default is used.
///   - onCancel: An optional closure that's called when the cropping is cancelled.
///   - onComplete: A closure that's called when the cropping is complete. This closure returns the cropped image.
///     If an error occurs the return value is nil.
public struct SwiftyCropView: View {
    private let maskShape: MaskShape
    private let configuration: SwiftyCropConfiguration
    private let onCancel: (() -> Void)?

    #if canImport(UIKit)
    private let imageToCrop: UIImage
    private let onComplete: (UIImage?) -> Void

    public init(
        imageToCrop: UIImage,
        maskShape: MaskShape,
        configuration: SwiftyCropConfiguration = SwiftyCropConfiguration(),
        onCancel: (() -> Void)? = nil,
        onComplete: @escaping (UIImage?) -> Void
    ) {
        self.imageToCrop = imageToCrop
        self.maskShape = maskShape
        self.configuration = configuration
        self.onCancel = onCancel
        self.onComplete = onComplete
    }
    #elseif canImport(AppKit)
    private let imageToCrop: NSImage
    private let onComplete: (NSImage?) -> Void

    public init(
        imageToCrop: NSImage,
        maskShape: MaskShape,
        configuration: SwiftyCropConfiguration = SwiftyCropConfiguration(),
        onCancel: (() -> Void)? = nil,
        onComplete: @escaping (NSImage?) -> Void
    ) {
        self.imageToCrop = imageToCrop
        self.maskShape = maskShape
        self.configuration = configuration
        self.onCancel = onCancel
        self.onComplete = onComplete
    }
    #endif

    public var body: some View {
        CropView(
            image: imageToCrop,
            maskShape: maskShape,
            configuration: configuration,
            onCancel: onCancel,
            onComplete: onComplete
        )
    }
}
