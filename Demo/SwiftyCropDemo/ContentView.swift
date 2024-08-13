import SwiftUI
import SwiftyCrop

#if canImport(UIKit)
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
typealias PlatformImage = NSImage
#endif

struct ContentView: View {
    @State private var showImageCropper: Bool = false
    @State private var selectedImage: PlatformImage?
    @State private var selectedShape: MaskShape = .square
    @State private var cropImageCircular: Bool
    @State private var rotateImage: Bool
    @State private var maxMagnificationScale: CGFloat
    @State private var maskRadius: CGFloat
    @State private var zoomSensitivity: CGFloat
    @FocusState private var textFieldFocused: Bool
    
    init() {
        let defaultConfiguration = SwiftyCropConfiguration()
        _cropImageCircular = State(initialValue: defaultConfiguration.cropImageCircular)
        _rotateImage = State(initialValue: defaultConfiguration.rotateImage)
        _maxMagnificationScale = State(initialValue: defaultConfiguration.maxMagnificationScale)
        _maskRadius = State(initialValue: defaultConfiguration.maskRadius)
        _zoomSensitivity = State(initialValue: defaultConfiguration.zoomSensitivity)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Group {
                if let selectedImage = selectedImage {
                    PlatformImageView(image: selectedImage)
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
#if canImport(UIKit)
                            maskRadius = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
#elseif canImport(AppKit)
                            if let screen = NSScreen.main {
                                maskRadius = min(screen.frame.width, screen.frame.height) / 2
                            } else {
                                maskRadius = 200 // Default value if no screen is available
                            }
#endif
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.footnote)
                        }
                        
                        DecimalTextField(value: $maskRadius)
                            .focused($textFieldFocused)
                    }
                    
                    HStack {
                        Text("Zoom sensitivity")
                        
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DecimalTextField(value: $zoomSensitivity)
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
        #if os(macOS)
        .sheet(isPresented: $showImageCropper) {
            imageCropperView
        }
        #else
        .fullScreenCover(isPresented: $showImageCropper) {
            imageCropperView
        }
        #endif
    }
    
    private var imageCropperView: some View {
        Group {
            if let selectedImage = selectedImage {
                SwiftyCropView(
                    imageToCrop: selectedImage,
                    maskShape: selectedShape,
                    configuration: SwiftyCropConfiguration(
                        maxMagnificationScale: maxMagnificationScale,
                        maskRadius: maskRadius,
                        cropImageCircular: cropImageCircular,
                        rotateImage: rotateImage,
                        zoomSensitivity: zoomSensitivity
                    )
                ) { croppedImage in
                    // Do something with the returned, cropped image
                    self.selectedImage = croppedImage
                }
            }
        }
        #if canImport(AppKit)
        .frame(width: 600, height: 400) // Adjust size as needed for macOS
        #endif
    }
    
    private func loadImage() {
        Task {
            selectedImage = await downloadExampleImage()
        }
    }
    
    // Example function for downloading an image
    private func downloadExampleImage() async -> PlatformImage? {
        let portraitUrlString = "https://picsum.photos/1000/1200"
        let landscapeUrlString = "https://picsum.photos/2000/1000"
        let urlString = Int.random(in: 0...1) == 0 ? portraitUrlString : landscapeUrlString
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = PlatformImage(data: data)
        else { return nil }
        
        return image
    }
}

struct PlatformImageView: View {
    let image: PlatformImage
    
    var body: some View {
        #if canImport(UIKit)
        Image(uiImage: image)
            .resizable()
        #elseif canImport(AppKit)
        Image(nsImage: image)
            .resizable()
        #endif
    }
}


#Preview {
    ContentView()
}
