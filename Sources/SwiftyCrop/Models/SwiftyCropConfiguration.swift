import CoreGraphics

/// `SwiftyCropConfiguration` is a struct that defines the configuration for cropping behavior.
public struct SwiftyCropConfiguration {
    public let maxMagnificationScale: CGFloat
    public let maskRadius: CGFloat
    public let cropImageCircular: Bool
    public let rotateImage: Bool
    public let zoomSensitivity: CGFloat
    public let rectAspectRatio: CGFloat
    public let customTexts: Texts?
    
    public struct Texts {
        public init(
            cancelButtonText: String,
            interactionInstructionsText: String,
            saveButtonText: String
        ) {
            self.cancelButtonText = cancelButtonText
            self.interactionInstructionsText = interactionInstructionsText
            self.saveButtonText = saveButtonText
        }
        
        public let cancelButtonText: String
        public let interactionInstructionsText: String
        public let saveButtonText: String
    }

    /// Creates a new instance of `SwiftyCropConfiguration`.
    ///
    /// - Parameters:
    ///   - maxMagnificationScale: The maximum scale factor that the image can be magnified while cropping.
    ///                            Defaults to `4.0`.
    ///   - maskRadius: The radius of the mask used for cropping.
    ///                            Defaults to `130`.
    ///   - cropImageCircular: Option to enable circular crop.
    ///                            Defaults to `false`.
    ///   - rotateImage: Option to rotate image.
    ///                            Defaults to `false`.
    ///   - zoomSensitivity: Sensitivity when zooming. Default is `1.0`. Decrease to increase sensitivity.
    ///
    ///   - rectAspectRatio: The aspect ratio to use when a `.rectangle` mask shape is used. Defaults to `4:3`.
    ///
    ///   - customTexts: `Texts` object when using custom texts for the cropping view.
    public init(
        maxMagnificationScale: CGFloat = 4.0,
        maskRadius: CGFloat = 130,
        cropImageCircular: Bool = false,
        rotateImage: Bool = false,
        zoomSensitivity: CGFloat = 1,
        rectAspectRatio: CGFloat = 4/3,
        customTexts: Texts? = nil
    ) {
        self.maxMagnificationScale = maxMagnificationScale
        self.maskRadius = maskRadius
        self.cropImageCircular = cropImageCircular
        self.rotateImage = rotateImage
        self.zoomSensitivity = zoomSensitivity
        self.rectAspectRatio = rectAspectRatio
        self.customTexts = customTexts
    }
}
