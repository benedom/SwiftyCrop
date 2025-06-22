import SwiftUI

struct CropView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CropViewModel
    
    private let image: UIImage
    private let maskShape: MaskShape
    private let configuration: SwiftyCropConfiguration
    private let onComplete: (UIImage?) -> Void
    private let localizableTableName: String
    
    init(
        image: UIImage,
        maskShape: MaskShape,
        configuration: SwiftyCropConfiguration,
        onComplete: @escaping (UIImage?) -> Void
    ) {
        self.image = image
        self.maskShape = maskShape
        self.configuration = configuration
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
    
    var body: some View {
        let magnificationGesture = MagnificationGesture()
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
        
        let dragGesture = DragGesture()
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
        
        let rotationGesture = RotationGesture()
            .onChanged { value in
                viewModel.angle = viewModel.lastAngle + value
            }
            .onEnded { _ in
                viewModel.lastAngle = viewModel.angle
            }
        
        VStack {
            InteractionInstructionsView(configuration: configuration, localizableTableName: localizableTableName)
                .padding(.top, 50)
                .zIndex(1)
            
            if configuration.rotateImageWithButtons {
                RotateButtonsView(viewModel: viewModel, configuration: configuration)
            }
            
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
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
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(viewModel.angle)
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .mask(
                        MaskShapeView(maskShape: maskShape)
                            .frame(width: viewModel.maskSize.width, height: viewModel.maskSize.height)
                    )
                
                ButtonsView(
                    configuration: configuration,
                    localizableTableName: localizableTableName,
                    dismiss: { dismiss() }
                ) {
                    onComplete(cropImage())
                    dismiss()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .simultaneousGesture(magnificationGesture)
            .simultaneousGesture(dragGesture)
            .simultaneousGesture(configuration.rotateImage ? rotationGesture : nil)
        }
        .background(configuration.colors.background)
    }
    
    private func updateOffset() {
        let maxOffsetPoint = viewModel.calculateDragGestureMax()
        let newX = min(max(viewModel.offset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
        let newY = min(max(viewModel.offset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
        viewModel.offset = CGSize(width: newX, height: newY)
        viewModel.lastOffset = viewModel.offset
    }
    
    private func cropImage() -> UIImage? {
        var editedImage: UIImage = image
        if configuration.rotateImage || configuration.rotateImageWithButtons {
            if let rotatedImage: UIImage = viewModel.rotate(
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
