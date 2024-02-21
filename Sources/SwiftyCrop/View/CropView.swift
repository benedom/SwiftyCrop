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
                maxMagnificationScale: configuration.maxMagnificationScale
            )
        )
        localizableTableName = "Localizable"
    }

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in
                let sensitivity: CGFloat = 0.2
                let scaledValue = (value.magnitude - 1) * sensitivity + 1

                let maxScaleValues = viewModel.calculateMagnificationGestureMaxValues()
                viewModel.scale = min(max(scaledValue * viewModel.scale, maxScaleValues.0), maxScaleValues.1)

                let maxOffsetPoint = viewModel.calculateDragGestureMax()
                let newX = min(max(viewModel.lastOffset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
                let newY = min(max(viewModel.lastOffset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
                viewModel.offset = CGSize(width: newX, height: newY)
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

        let combinedGesture = magnificationGesture.simultaneously(with: dragGesture)

        VStack {
            Text("interaction_instructions", tableName: localizableTableName, bundle: .module)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .padding(.top, 30)
                .zIndex(1)

            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .opacity(0.5)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    viewModel.imageSizeInView = geometry.size
                                }
                        }
                    )

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .mask(
                        MaskShapeView(maskShape: maskShape)
                            .frame(width: viewModel.maskRadius * 2, height: viewModel.maskRadius * 2)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(combinedGesture)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("cancel_button", tableName: localizableTableName, bundle: .module)
                }
                .foregroundColor(.white)

                Spacer()

                Button {
                    onComplete(cropImage())
                    dismiss()
                } label: {
                    Text("save_button", tableName: localizableTableName, bundle: .module)
                }
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding()
        }
        .background(.black)
    }

    private func cropImage() -> UIImage? {
        if maskShape == .circle && configuration.cropImageCircular {
            return viewModel.cropToCircle(image)
        } else {
            return viewModel.cropToSquare(image)
        }
    }

    private struct MaskShapeView: View {
        let maskShape: MaskShape

        var body: some View {
            Group {
                switch maskShape {
                case .circle:
                    Circle()

                case .square:
                    Rectangle()
                }
            }
        }
    }
}
