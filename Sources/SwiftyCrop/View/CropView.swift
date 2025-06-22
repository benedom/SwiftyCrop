import SwiftUI
import PhotosUI

struct CropView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CropViewModel
    
    @State private var isCropping: Bool = false

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

    // MARK: - Body
    var body: some View {
        ZStack {
            VStack {
                InteractionInstructionsView(configuration: configuration, localizableTableName: localizableTableName)
                    .padding(.top, 50)
                    .zIndex(1)
                
                if configuration.rotateImageWithButtons {
                    RotateButtonsView(viewModel: viewModel, configuration: configuration)
                }
                
                Spacer()
                
                cropImageView
                
                Spacer()
                
                ButtonsView(
                    configuration: configuration,
                    localizableTableName: localizableTableName,
                    dismiss: { dismiss() }
                ) {
                    Task {
                        isCropping = true
                        let result = cropImage()
                        await MainActor.run {
                            onComplete(result)
                            dismiss()
                        }
                    }
                }
            }
            .background(configuration.colors.background)
            
            if isCropping {
                progressLayer
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .simultaneousGesture(magnificationGesture)
        .simultaneousGesture(dragGesture)
        .simultaneousGesture(configuration.rotateImage ? rotationGesture : nil)
    }

    private var cropToolbar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text(
                    configuration.texts.cancelButton ??
                    NSLocalizedString("cancel_button", tableName: localizableTableName, bundle: .module, comment: "")
                )
                .padding()
                .font(configuration.fonts.cancelButton)
                .foregroundColor(configuration.colors.cancelButton)
            }
            .padding()
            
            Spacer()
            
            Button {
                Task {
                    isCropping = true
                    let result = cropImage()
                    await MainActor.run {
                        onComplete(result)
                        dismiss()
                    }
                }
            } label: {
                Text(
                    configuration.texts.saveButton ??
                    NSLocalizedString("save_button", tableName: localizableTableName, bundle: .module, comment: "")
                )
                .padding()
                .font(configuration.fonts.saveButton)
                .foregroundColor(configuration.colors.saveButton)
            }
            .padding()
            .disabled(isCropping)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }

    private var progressLayer: some View {
        ZStack {
            configuration.colors.background.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 5) {
                
                Spacer(minLength: 35)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: configuration.colors.interactionInstructions))
                    .scaleEffect(1.2)
                
                Spacer()
                
                Text(
                    configuration.texts.progressLayerText ??
                    NSLocalizedString("processing_label", tableName: localizableTableName, bundle: .module, comment: "")
                )
                .font(.body)
                .foregroundColor(configuration.colors.interactionInstructions)
                .padding(.bottom, 12)
                
            }
            .frame(width: 120, height: 110)
            .background(configuration.colors.background.opacity(0.8))
            .cornerRadius(12)
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
        }
        .transition(.opacity)
    }

    // MARK: - Helpers
    private func updateOffset() {
        let maxOffsetPoint = viewModel.calculateDragGestureMax()
        let newX = min(max(viewModel.offset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
        let newY = min(max(viewModel.offset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
        viewModel.offset = CGSize(width: newX, height: newY)
        viewModel.lastOffset = viewModel.offset
    }

    private func cropImage() -> UIImage? {
        var editedImage: UIImage = image
        if configuration.rotateImage {
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
