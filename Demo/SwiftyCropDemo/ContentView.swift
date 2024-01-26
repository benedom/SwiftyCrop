//
//  ContentView.swift
//  SwiftyCropDemo
//
//  Created by Leonid Zolotarev on 1/23/24.
//

import SwiftUI
import SwiftyCrop

struct ContentView: View {
    @State private var showImageCropper: Bool = false
    @State private var selectedImage: UIImage?
    @State private var selectedShape: MaskShape = .square
    @State private var cropImageCircular: Bool = false

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
                    ShapeButton(
                        title: "Use square crop",
                        shape: .square,
                        selection: $selectedShape
                    )
                    ShapeButton(
                        title: "Use circle crop",
                        shape: .circle,
                        selection: $selectedShape
                    )
                }
                Toggle("Crop image to circle", isOn: $cropImageCircular)
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
                        cropImageCircular: cropImageCircular
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
