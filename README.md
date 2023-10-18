# SwiftyCrop

// TODO: Screenshots, GIFs

## 🔭 Overview
SwiftyCrop allows users to seamlessly crop images within their SwiftUI applications. It provides a user-friendly interface that makes cropping an image as simple as selecting the desired area.

With SwiftyCrop, you can easily adjust the cropping area, maintain aspect ratio, zoom in and out for precise cropping.

The following languages are supported & localized:
- 🇬🇧 English
- 🇩🇪 German
- 🇫🇷 French
- 🇮🇹 Italian
- 🇷🇺 Russian
- 🇪🇸 Spanish
- 🇹🇷 Turkish
- 🇺🇦 Ukrainian

The localization file can be found in `Sources/SwiftyCrop/Resources`.

## 📕 Contents

- [Requirements](#🧳-requirements)
- [Installation](#💻-installation)
- [Usage](#🛠️-usage)
- [Contributors](#👨‍💻-contributors)
- [Author](#✍️-author)
- [License](#📃-license)

## 🧳 Requirements

- iOS 16.0 or later
- Xcode 14.3 or later
- Swift 5.0 or later


## 💻 Installation
There are two ways to use SwiftyCrop in your project:
- using Swift Package Manager
- manual install (embed Xcode Project)

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate `SwiftyCrop` into your Xcode project using Xcode 14.3 or later, specify it in `File > Swift Packages > Add Package Dependency...`:

```ogdl
https://github.com/elai950/AlertToast.git, :branch="master" // TODO: Adjust URL
```

### Manually

If you prefer not to use any of dependency managers, you can integrate `SwiftyCrop` into your project manually. Put `Sources/SwiftyCrop` folder in your Xcode project. Make sure to enable `Copy items if needed` and `Create groups`.

## 🛠️ Usage

### Quick Start
This example shows how to display `SwiftyCropView` in a full screen cover after an image has been set.
```swift
import SwiftUI
import SwiftyCrop

struct ExampleView: View {
    @State private var showImageCropper: Bool = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            /*
            Your view implementation here.

            Update `selectedImage` with the image you want to crop,
            e.g. after picking it from the library or downloading it.

            As soon as you have done this, toggle `showImageCropper`.
            
            Below is a sample implementation:
             */

             Button("Show cropper") {
                selectedImage = UIImage(named: "") // TODO: Test
                showImageCropper.toggle()
             }

        }
        .fullScreenCover(isPresented: $showImageCropper) {
            if let selectedImage = selectedImage {
                SwiftyCropView(
                    imageToCrop: selectedImage,
                    maskShape: .square
                ) { croppedImage in
                    // Do something with the returned cropped image
                }
            }
        }
    }
}
```

You can also configure `SwiftyCropView` by passing a `SwiftyCropConfiguration`:
```swift
let configuration = SwiftyCropConfiguration(
    maxMagnificationScale = 4.0,
    maskRadius: 130
)
```

```swift
.fullScreenCover(isPresented: $showImageCropper) {
            if let selectedImage = selectedImage {
                SwiftyCropView(
                    imageToCrop: selectedImage,
                    maskShape: .square,
                    configuration: configuration // Use the configuration
                ) { croppedImage in
                    // Do something with the returned cropped image
                }
            }
        }
```

## 👨‍💻 Contributors

All issue reports, feature requests, pull requests and GitHub stars are welcomed and much appreciated.

## ✍️ Author

Benedikt Betz

## 📃 License

`SwiftyCrop` is available under the MIT license. See the [LICENSE](https://github.com/elai950/AlertToast/blob/master/LICENSE.md) file for more info. // TODO