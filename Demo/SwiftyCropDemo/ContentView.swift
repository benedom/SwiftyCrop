import SwiftUI
import SwiftyCrop

struct ContentView: View {
  @State private var showImageCropper: Bool = false
  @State private var selectedImage: UIImage?
  @State private var selectedShape: MaskShape = .square
  @State private var rectAspectRatio: PresetAspectRatios = .fourToThree
  @State private var cropImageCircular: Bool
  @State private var rotateImage: Bool
  @State private var rotateImageWithButtons: Bool
  @State private var usesLiquidGlassDesign: Bool
  @State private var maxMagnificationScale: CGFloat
  @State private var maskRadius: CGFloat
  @State private var zoomSensitivity: CGFloat
  @FocusState private var textFieldFocused: Bool
  
  enum PresetAspectRatios: String, CaseIterable {
    case fourToThree = "4:3"
    case sixteenToNine = "16:9"
    
    func getValue() -> CGFloat {
      switch self {
      case .fourToThree:
        4/3
        
      case .sixteenToNine:
        16/9
      }
    }
  }
  
  init() {
    let defaultConfiguration = SwiftyCropConfiguration()
    _cropImageCircular = State(initialValue: defaultConfiguration.cropImageCircular)
    _rotateImage = State(initialValue: defaultConfiguration.rotateImage)
    _rotateImageWithButtons = State(initialValue: defaultConfiguration.rotateImageWithButtons)
    _usesLiquidGlassDesign = State(initialValue: defaultConfiguration.usesLiquidGlassDesign)
    _maxMagnificationScale = State(initialValue: defaultConfiguration.maxMagnificationScale)
    _maskRadius = State(initialValue: defaultConfiguration.maskRadius)
    _zoomSensitivity = State(initialValue: defaultConfiguration.zoomSensitivity)
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
            
            Picker("maskShape", selection: $selectedShape.animation()) {
              ForEach(MaskShape.allCases, id: \.self) { mask in
                Text(String(describing: mask))
              }
            }
            .pickerStyle(.segmented)
          }
          
          if selectedShape == .rectangle {
            HStack {
              Text("Rect aspect ratio")
                .frame(maxWidth: .infinity, alignment: .leading)
              
              Picker("rectAspectRatio", selection: $rectAspectRatio) {
                ForEach(PresetAspectRatios.allCases, id: \.self) { aspectRatio in
                  Text(aspectRatio.rawValue)
                }
                
              }
              .pickerStyle(.segmented)
            }
          }
          
          Toggle("Crop image to circle", isOn: $cropImageCircular)
          
          Toggle("Rotate image (gestures)", isOn: $rotateImage)
          
          Toggle("Rotate image (buttons)", isOn: $rotateImageWithButtons)
          
          if #available(iOS 26, *) {
            Toggle("Liquid Glass design", isOn: $usesLiquidGlassDesign)
          }
          
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
              maskRadius = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
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
    .fullScreenCover(isPresented: $showImageCropper) {
      if let selectedImage = selectedImage {
        SwiftyCropView(
          imageToCrop: selectedImage,
          maskShape: selectedShape,
          configuration: SwiftyCropConfiguration(
            maxMagnificationScale: maxMagnificationScale,
            maskRadius: maskRadius,
            cropImageCircular: cropImageCircular,
            rotateImage: rotateImage,
            rotateImageWithButtons: rotateImageWithButtons,
            usesLiquidGlassDesign: usesLiquidGlassDesign,
            zoomSensitivity: zoomSensitivity,
            rectAspectRatio: rectAspectRatio.getValue()
          )
        ) { croppedImage in
          // Do something with the returned, cropped image
          self.selectedImage = croppedImage
        }.clipped(antialiased: false)
          .ignoresSafeArea(edges: .all)
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
    let portraitUrlString = "https://picsum.photos/1000/1200"
    let landscapeUrlString = "https://picsum.photos/2000/1000"
    let urlString = Int.random(in: 0...1) == 0 ? portraitUrlString : landscapeUrlString
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
