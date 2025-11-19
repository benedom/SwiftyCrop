import SwiftUI

/// `SwiftyCropView` is a SwiftUI view for cropping images.
///
/// You can customize the cropping behavior using a `SwiftyCropConfiguration` instance and a completion handler.
///
/// - Parameters:
///   - imageToCrop: The image to be cropped.
///   - maskShape: The shape of the mask used for cropping.
///   - configuration: The configuration for the cropping behavior. If nothing is specified, the default is used.
///   - onCancel: An optional closure that's called when the cropping is cancelled.
///   - onMaskGeometry: An optional callback closure that provides frame and geometry information about the mask in the crop view. This closure returns a `CGRect`.
///   - onComplete: A closure that's called when the cropping is complete. This closure returns the cropped `UIImage?`.
///     If an error occurs the return value is nil.
public struct SwiftyCropView: View {
  private let imageToCrop: UIImage
  private let maskShape: MaskShape
  private let configuration: SwiftyCropConfiguration
  private let onCancel: (() -> Void)?
  private let onMaskGeometry: ((CGRect) -> Void)?
  private let onComplete: (UIImage?) -> Void

  public init(
    imageToCrop: UIImage,
    maskShape: MaskShape,
    configuration: SwiftyCropConfiguration = SwiftyCropConfiguration(),
    onCancel: (() -> Void)? = nil,
    onMaskGeometry: ((CGRect) -> Void)? = nil,
    onComplete: @escaping (UIImage?) -> Void
  ) {
    self.imageToCrop = imageToCrop
    self.maskShape = maskShape
    self.configuration = configuration
    self.onCancel = onCancel
    self.onMaskGeometry = onMaskGeometry
    self.onComplete = onComplete
  }

  public var body: some View {
    CropView(
      image: imageToCrop,
      maskShape: maskShape,
      configuration: configuration,
      onCancel: onCancel,
      onMaskGeometry: onMaskGeometry,
      onComplete: onComplete
    )
  }
}
