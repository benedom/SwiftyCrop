import SwiftUI
#if canImport(UIKit)
import PhotosUI
#endif

struct CropView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: CropViewModel

  @State private var isCropping: Bool = false

  private let image: PlatformImage
  private let maskShape: MaskShape
  private let configuration: SwiftyCropConfiguration
  private let onCancel: (() -> Void)?
  private let onComplete: (PlatformImage?) -> Void
  private let localizableTableName: String

  init(
    image: PlatformImage,
    maskShape: MaskShape,
    configuration: SwiftyCropConfiguration,
    onCancel: (() -> Void)? = nil,
    onComplete: @escaping (PlatformImage?) -> Void
  ) {
    self.image = image
    self.maskShape = maskShape
    self.configuration = configuration
    self.onCancel = onCancel
    self.onComplete = onComplete
    _viewModel = StateObject(
      wrappedValue: CropViewModel(
        maskRadius: configuration.maskRadius,
        maxMagnificationScale: configuration.maxMagnificationScale,
        maskShape: maskShape,
        rectAspectRatio: configuration.rectAspectRatio
      )
    )
    localizableTableName = "Localizable"
  }
  
  // MARK: - Body
  var body: some View {
#if compiler(>=6.2) // Use this to prevent compiling of unavailable iOS 26 / macOS 26 APIs
    if configuration.usesLiquidGlassDesign,
       #available(iOS 26, visionOS 26.0, macOS 26.0, *) {
      buildLiquidGlassBody(configuration: configuration)
    } else {
      buildLegacyBody(configuration: configuration)
    }
#else
    buildLegacyBody(configuration: configuration)
#endif
  }

  @available(iOS 26, visionOS 26.0, macOS 26.0, *)
  private func buildLiquidGlassBody(configuration: SwiftyCropConfiguration) -> some View {
    ZStack {
      VStack {
        ToolbarView(
          viewModel: viewModel,
          configuration: configuration,
          dismiss: {
            onCancel?()
            dismiss()
          }
        ) {
          await MainActor.run {
            isCropping = true
          }
          let result = cropImage()
          await MainActor.run {
            onComplete(result)
            dismiss()
            isCropping = false
          }
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
        .zIndex(1)
        
        Spacer()
        
        cropImageView
        
        Spacer()
      }
      .background(configuration.colors.background)
      
      if isCropping {
        ProgressLayer(configuration: configuration, localizableTableName: localizableTableName)
      }
    }
  }
  
  private func buildLegacyBody(configuration: SwiftyCropConfiguration) -> some View {
    ZStack {
      VStack {
        Legacy_InteractionInstructionsView(configuration: configuration, localizableTableName: localizableTableName)
          .padding(.top, 50)
          .zIndex(1)
        
        if configuration.rotateImageWithButtons {
          Legacy_RotateButtonsView(viewModel: viewModel, configuration: configuration)
            .zIndex(1)
        }
        
        Spacer()
        
        cropImageView
        
        Spacer()
        
        Legacy_ButtonsView(
          configuration: configuration,
          localizableTableName: localizableTableName,
          dismiss: {
            onCancel?()
            dismiss()
          }
        ) {
          await MainActor.run {
            isCropping = true
          }
          let result = cropImage()
          await MainActor.run {
            onComplete(result)
            dismiss()
            isCropping = false
          }
        }
      }
      .background(configuration.colors.background)
      
      if isCropping {
        Legacy_ProgressLayer(configuration: configuration, localizableTableName: localizableTableName)
      }
    }
  }
  
  // MARK: - Gestures
  private var magnificationGesture: some Gesture {
    MagnificationGesture()
      .onChanged { value in
        let sensitivity: CGFloat = 0.1 * configuration.zoomSensitivity
        let scaledValue = (value.magnitude - 1) * sensitivity + 1
        
        let maxScaleValues = viewModel.calculateMagnificationGestureMaxValues()
        viewModel.scale = min(max(scaledValue * viewModel.lastScale, maxScaleValues.0), maxScaleValues.1)
        
        updateOffset()
      }
      .onEnded { _ in
        viewModel.lastScale = viewModel.scale
        viewModel.lastOffset = viewModel.offset
      }
  }
  
  private var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        let maxOffsetPoint = viewModel.calculateDragGestureMax()
        let newX = min(
          max(value.translation.width + viewModel.lastOffset.width, -maxOffsetPoint.x),
          maxOffsetPoint.x
        )
        let newY = min(
          max(value.translation.height + viewModel.lastOffset.height, -maxOffsetPoint.y),
          maxOffsetPoint.y
        )
        viewModel.offset = CGSize(width: newX, height: newY)
      }
      .onEnded { _ in
        viewModel.lastOffset = viewModel.offset
      }
  }
  
  private var rotationGesture: some Gesture {
    RotationGesture()
      .onChanged { value in
        viewModel.angle = viewModel.lastAngle + value
      }
      .onEnded { _ in
        viewModel.lastAngle = viewModel.angle
      }
  }
  
  // MARK: - UI Components
  private var cropImageView: some View {
    ZStack {
      PlatformImageView(image: image)
        .rotationEffect(viewModel.angle)
        .scaleEffect(viewModel.scale)
        .offset(viewModel.offset)
        .opacity(0.5)
        .overlay(
          GeometryReader { geometry in
            Color.clear
              .onAppear {
                viewModel.updateMaskDimensions(for: geometry.size)
              }
          }
        )

      PlatformImageView(image: image)
        .rotationEffect(viewModel.angle)
        .scaleEffect(viewModel.scale)
        .offset(viewModel.offset)
        .mask(
          MaskShapeView(maskShape: maskShape)
            .frame(width: viewModel.maskSize.width, height: viewModel.maskSize.height)
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .simultaneousGesture(magnificationGesture)
    .simultaneousGesture(dragGesture)
    .simultaneousGesture(configuration.rotateImage ? rotationGesture : nil)
  }
  
  // MARK: - Helpers
  private func updateOffset() {
    let maxOffsetPoint = viewModel.calculateDragGestureMax()
    let newX = min(max(viewModel.offset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
    let newY = min(max(viewModel.offset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
    viewModel.offset = CGSize(width: newX, height: newY)
    viewModel.lastOffset = viewModel.offset
  }
  
  private func cropImage() -> PlatformImage? {
    var editedImage: PlatformImage = image
    if configuration.rotateImage || configuration.rotateImageWithButtons {
      if let rotatedImage: PlatformImage = viewModel.rotate(
        editedImage,
        viewModel.lastAngle
      ) {
        editedImage = rotatedImage
      }
    }
    if configuration.cropImageCircular && maskShape == .circle {
      return viewModel.cropToCircle(editedImage)
    } else if maskShape == .rectangle {
      return viewModel.cropToRectangle(editedImage)
    } else {
      return viewModel.cropToSquare(editedImage)
    }
  }
  
  // MARK: - Mask Shape View
  private struct MaskShapeView: View {
    let maskShape: MaskShape

    var body: some View {
      Group {
        switch maskShape {
        case .circle:
          Circle()
        case .square, .rectangle:
          Rectangle()
        }
      }
    }
  }
}

// MARK: - Platform Image View
struct PlatformImageView: View {
  let image: PlatformImage

  var body: some View {
    #if canImport(UIKit)
    Image(uiImage: image)
      .resizable()
      .scaledToFit()
    #elseif canImport(AppKit)
    Image(nsImage: image)
      .resizable()
      .scaledToFit()
    #endif
  }
}
