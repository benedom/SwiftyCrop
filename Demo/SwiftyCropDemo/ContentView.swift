import SwiftUI
import SwiftyCrop

struct ContentView: View {
    @State private var showImageCropper: Bool = false
    @State private var selectedImage: UIImage?
    @State private var selectedShape: MaskShape = .square
    @State private var cropImageCircular: Bool
    @State private var rotateImage: Bool
    @State private var maxMagnificationScale: CGFloat
    @State private var maskRadius: CGFloat
    @FocusState private var textFieldFocused: Bool
    
    init() {
        let defaultConfiguration = SwiftyCropConfiguration()
        _cropImageCircular = State(initialValue: defaultConfiguration.cropImageCircular)
        _rotateImage = State(initialValue: defaultConfiguration.rotateImage)
        _maxMagnificationScale = State(initialValue: defaultConfiguration.maxMagnificationScale)
        _maskRadius = State(initialValue: defaultConfiguration.maskRadius)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Group {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                } else {
                    ProgressView()
                }
            }
            .scaledToFit()
            .padding()
            
            Spacer()
            
            GroupBox {
                VStack(spacing: 15) {
                    HStack {
                        Button {
                            loadImage()
                        } label: {
                            LongText(title: "Load image")
                        }
                        Button {
                            showImageCropper.toggle()
                        } label: {
                            LongText(title: "Crop image")
                        }
                    }
                    
                    HStack {
                        Text("Mask shape")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Picker("maskShape", selection: $selectedShape) {
                            ForEach(MaskShape.allCases, id: \.self) { mask in
                                Text(String(describing: mask))
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Toggle("Crop image to circle", isOn: $cropImageCircular)
                    
                    Toggle("Rotate image", isOn: $rotateImage)
                    
                    HStack {
                        Text("Max magnification")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DecimalTextField(value: $maxMagnificationScale)
                            .focused($textFieldFocused)
                    }
                    
                    HStack {
                        Text("Mask radius")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            maskRadius = UIScreen.main.bounds.width / 2
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.footnote)
                        }
                        
                        DecimalTextField(value: $maskRadius)
                            .focused($textFieldFocused)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        textFieldFocused = false
                    }
                }
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .onAppear {
            loadImage()
        }
        .fullScreenCover(isPresented: $showImageCropper) {
            if let selectedImage = selectedImage {
                SwiftyCropView(
                    imageToCrop: selectedImage,
                    maskShape: selectedShape,
                    configuration: SwiftyCropConfiguration(
                        maxMagnificationScale: maxMagnificationScale,
                        maskRadius: maskRadius,
                        cropImageCircular: cropImageCircular,
                        rotateImage: rotateImage
                    )
                ) { croppedImage in
                    // Do something with the returned, cropped image
                    self.selectedImage = croppedImage
                }
            }
        }
    }
    
    private func loadImage() {
        Task {
            selectedImage = await downloadExampleImage()
        }
    }
    
    // Example function for downloading an image
    private func downloadExampleImage() async -> UIImage? {
        let urlString = "https://picsum.photos/1000/1200"
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data)
        else { return nil }
        
        return image
    }
}

#Preview {
    ContentView()
}
