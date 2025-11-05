import CoreGraphics
import SwiftUI

/// `SwiftyCropConfiguration` is a struct that defines the configuration for cropping behavior and the UI.
public struct SwiftyCropConfiguration {
  public let maxMagnificationScale: CGFloat
  public let maskRadius: CGFloat
  public let cropImageCircular: Bool
  public let rotateImage: Bool
  public let rotateImageWithButtons: Bool
  public let usesLiquidGlassDesign: Bool
  public let zoomSensitivity: CGFloat
  public let rectAspectRatio: CGFloat
  public let texts: Texts
  public let fonts: Fonts
  public let colors: Colors
  
  /// Creates a new instance of `Texts` that are used in the cropping view.
  /// - Note: The new LiquidGlass design does not use texts anymore but icon buttons. Setting this when Liquid Glass is enabled will not have any effect.
  ///
  /// - Parameters:
  ///   - cancelButton: The text for the cancel button. Defaults to `nil`, using localized values from the app.
  ///   - interactionInstructions: The text for the interaction instructions. Defaults to `nil`, using localized values from the app.
  ///   - saveButton: The text for the save button. Defaults to `nil`, using localized values from the app.
  ///   - progressLayerText: The text for the progress view indicating that cropping occurs. Defaults to `nil`, using localized values from the app.
  public struct Texts {
    public init(
      // We cannot use the localized values here because module access is not given in init
      cancelButton: String? = nil,
      interactionInstructions: String? = nil,
      saveButton: String? = nil,
      progressLayerText: String? = nil
    ) {
      self.cancelButton = cancelButton
      self.interactionInstructions = interactionInstructions
      self.saveButton = saveButton
      self.progressLayerText = progressLayerText
    }
    
    public let cancelButton: String?
    public let interactionInstructions: String?
    public let saveButton: String?
    public let progressLayerText: String?
  }
  
  /// Creates a new instance of `Fonts` that are used in the cropping view texts.
  /// - Note: The new LiquidGlass design does not use texts anymore but icon buttons. Setting this when Liquid Glass is enabled will not have any effect.
  ///
  /// - Parameters:
  ///   - cancelButton: The font for the cancel button text. Defaults to `nil`, using default values.
  ///   - interactionInstruction: The font for the interaction instruction text. Defaults to `nil`, using default values.
  ///   - saveButton: The font for the save button text. Defaults to `nil`, using default values.
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
  
  /// Creates a new instance of `Colors` that are used in the cropping view.
  /// - Note: Certain properties have different effects whether Liquid Glass is enabled or not.
  ///
  /// - Parameters:
  ///   - cancelButton: The color for the cancel button text. If Liquid Glass is enabled, will be the color of the icon. Defaults to `.white`.
  ///   - cancelButtonBackground: If Liquid Glass is enabled, will be the background color of the button. Otherwise has no effect. Defaults to `.clear`.
  ///   - interactionInstructions: The color for the interaction instructions text. Defaults to `.white`.
  ///   - rotateButton: The color for the rotate button text. If Liquid Glass is enabled, will be the color of the icon. Defaults to `.white`.
  ///   - rotateButtonBackground: If Liquid Glass is enabled, will be the background color of the button. Otherwise has no effect. Defaults to `.clear`.
  ///   - resetRotationButton: The color for the reset rotation button text. If Liquid Glass is enabled, will be the color of the icon. Defaults to `.white`.
  ///   - resetRotationButtonBackground: If Liquid Glass is enabled, will be the background color of the button. Otherwise has no effect. Defaults to `.clear`.
  ///   - saveButton: The color for the save button text. If Liquid Glass is enabled, will be the color of the icon. Defaults to `.white`.
  ///   - saveButtonBackground: If Liquid Glass is enabled, will be the background color of the button. Otherwise has no effect. Defaults to `.yellow`.
  ///   - background: The background color of the entire cropping view. Defaults to `.black`.
  ///   - cropOuterMask: The color of the crop outer mask. Can be used to tint it in case you are using very light/dark images which make the cropping view hard to see. Defaults to `.clear` since it is mostly not needed
  public struct Colors {
    public init(
      cancelButton: Color = .white,
      cancelButtonBackground: Color = .clear,
      interactionInstructions: Color = .white,
      rotateButton: Color = .white,
      rotateButtonBackground: Color = .clear,
      resetRotationButton: Color = .white,
      resetRotationButtonBackground: Color = .clear,
      saveButton: Color = .white,
      saveButtonBackground: Color = .yellow,
      background: Color = .black,
      cropOuterMask: Color = .clear
    ) {
      self.cancelButton = cancelButton
      self.cancelButtonBackground = cancelButtonBackground
      self.interactionInstructions = interactionInstructions
      self.rotateButton = rotateButton
      self.rotateButtonBackground = rotateButtonBackground
      self.resetRotationButton = resetRotationButton
      self.resetRotationButtonBackground = resetRotationButtonBackground
      self.saveButton = saveButton
      self.saveButtonBackground = saveButtonBackground
      self.background = background
      self.cropOuterMask = cropOuterMask
    }
    
    public let cancelButton: Color
    public let cancelButtonBackground: Color
    public let interactionInstructions: Color
    public let rotateButton: Color
    public let rotateButtonBackground: Color
    public let resetRotationButton: Color
    public let resetRotationButtonBackground: Color
    public let saveButton: Color
    public let saveButtonBackground: Color
    public let background: Color
    public let cropOuterMask: Color
  }
  
  /// Creates a new instance of `SwiftyCropConfiguration`.
  ///
  /// - Parameters:
  ///   - maxMagnificationScale: The maximum scale factor that the image can be magnified while cropping. Defaults to `4.0`.
  ///
  ///   - maskRadius: The radius of the mask used for cropping. Defaults to `130`.
  ///
  ///   - cropImageCircular: Option to enable circular crop. Defaults to `false`.
  ///
  ///   - rotateImage: Option to rotate image. Defaults to `false`.
  ///
  ///   - rotateImageWithButtons: Option to show rotation buttons. Defaults to `false`.
  ///
  ///   - usesLiquidGlassDesign: Apply the all new liquid glass design. Defaults to `#available(iOS 26,*)*`.
  ///
  ///   - zoomSensitivity: Sensitivity when zooming. Default is `1.0`. Decrease to increase sensitivity.
  ///
  ///   - rectAspectRatio: The aspect ratio to use when a `.rectangle` mask shape is used. Defaults to `4:3`.
  ///
  ///   - texts: `Texts` object when using custom texts for the cropping view.
  ///
  ///   - fonts: `Fonts` object when using custom fonts for the cropping view. Defaults to system.
  ///
  ///   - colors: `Colors` object when using custom colors for the cropping view.
  public init(
    maxMagnificationScale: CGFloat = 4.0,
    maskRadius: CGFloat = 130,
    cropImageCircular: Bool = false,
    rotateImage: Bool = false,
    rotateImageWithButtons: Bool = false,
    usesLiquidGlassDesign: Bool? = nil,
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
    self.rotateImageWithButtons = rotateImageWithButtons
    self.zoomSensitivity = zoomSensitivity
    self.rectAspectRatio = rectAspectRatio
    self.texts = texts
    self.fonts = fonts
    self.colors = colors
    
    self.usesLiquidGlassDesign = {
      guard let usesLiquidGlassDesign else {
        if #available(iOS 26, *) {
          return true
        } else {
          return false
        }
      }
      return usesLiquidGlassDesign
    }()
  }
}
