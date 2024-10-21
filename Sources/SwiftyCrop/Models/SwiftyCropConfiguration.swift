import CoreGraphics
import SwiftUI

/// `SwiftyCropConfiguration` is a struct that defines the configuration for cropping behavior.
public struct SwiftyCropConfiguration {
    public let maxMagnificationScale: CGFloat
    public let maskRadius: CGFloat
    public let cropImageCircular: Bool
    public let rotateImage: Bool
    public let zoomSensitivity: CGFloat
    public let rectAspectRatio: CGFloat
    public let texts: Texts
    public let fonts: Fonts
    public let colors: Colors

    public struct Texts {
        public init(
            // We cannot use the localized values here because module access is not given in init
            cancelButton: String? = nil,
            interactionInstructions: String? = nil,
            saveButton: String? = nil
        ) {
            self.cancelButton = cancelButton
            self.interactionInstructions = interactionInstructions
            self.saveButton = saveButton
        }
        
        public let cancelButton: String?
        public let interactionInstructions: String?
        public let saveButton: String?
    }

    public struct Fonts {
        public init(
            cancelButton: Font? = nil,
            interactionInstructions: Font? = nil,
            saveButton: Font? = nil
        ) {
            self.cancelButton = cancelButton
            self.interactionInstructions = interactionInstructions ?? .system(size: 16, weight: .regular)
            self.saveButton = saveButton
        }

        public let cancelButton: Font?
        public let interactionInstructions: Font
        public let saveButton: Font?
    }
    
    public struct Colors {
        public init(
            cancelButton: Color = .white,
            interactionInstructions: Color = .white,
            saveButton: Color = .white,
            background: Color = .black
        ) {
            self.cancelButton = cancelButton
            self.interactionInstructions = interactionInstructions
            self.saveButton = saveButton
            self.background = background
        }

        public let cancelButton: Color
        public let interactionInstructions: Color
        public let saveButton: Color
        public let background: Color
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
    ///   - texts: `Texts` object when using custom texts for the cropping view.
    ///
    ///   - fonts: `Fonts` object when using custom fonts for the cropping view. Defaults to system.
    ///
    ///   - colors: `Colors` object when using custom colors for the cropping view. Defaults to white text and black background.
    public init(
        maxMagnificationScale: CGFloat = 4.0,
        maskRadius: CGFloat = 130,
        cropImageCircular: Bool = false,
        rotateImage: Bool = false,
        zoomSensitivity: CGFloat = 1,
        rectAspectRatio: CGFloat = 4/3,
        texts: Texts = Texts(),
        fonts: Fonts = Fonts(),
        colors: Colors = Colors()
    ) {
        self.maxMagnificationScale = maxMagnificationScale
        self.maskRadius = maskRadius
        self.cropImageCircular = cropImageCircular
        self.rotateImage = rotateImage
        self.zoomSensitivity = zoomSensitivity
        self.rectAspectRatio = rectAspectRatio
        self.texts = texts
        self.fonts = fonts
        self.colors = colors
    }
}
