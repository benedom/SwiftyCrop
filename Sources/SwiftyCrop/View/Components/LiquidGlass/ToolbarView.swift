import SwiftUI

@available(iOS 26, visionOS 26.0, *)
struct ToolbarView: View {
  @ObservedObject var viewModel: CropViewModel
  let configuration: SwiftyCropConfiguration
  let dismiss: () -> Void
  let onComplete: () async -> Void
  @State private var isCropping = false
  
  var body: some View {
#if compiler(>=6.2) // Use this to prevent compiling of unavailable iOS 26 APIs
    HStack {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .foregroundStyle(configuration.colors.cancelButton)
          .fontWeight(.semibold)
      }
      .padding()
#if !os(visionOS)
      .glassEffect()
#endif

      Spacer()
      
      if configuration.rotateImageWithButtons {
        Button {
          // The reset button should only reset by the amount needed, prevents rotating the image back multiple times if it was rotated multiple times
          let numberOfFullCircles = Int(viewModel.angle.degrees / 360)
          let newValue = Double(numberOfFullCircles * 360)
          withAnimation {
            viewModel.angle = Angle(degrees: newValue)
            viewModel.lastAngle = viewModel.angle
          }
        } label: {
          Image(systemName: "arrow.uturn.backward.circle")
            .foregroundStyle(configuration.colors.rotateButton)
            .fontWeight(.semibold)
        }
        .padding()
#if !os(visionOS)
        .glassEffect()
#endif
        .opacity(viewModel.angle.degrees.truncatingRemainder(dividingBy: 360) == 0 ? 0.7 : 1)
        .disabled(viewModel.angle.degrees.truncatingRemainder(dividingBy: 360) == 0)
        
        HStack {
          Button {
            withAnimation {
              viewModel.angle.degrees -= 90
              viewModel.lastAngle = viewModel.angle
            }
          } label: {
            Image(systemName: "rotate.left")
              .foregroundStyle(configuration.colors.rotateButton)
              .fontWeight(.semibold)
          }
          .padding()
          
          Button {
            withAnimation {
              viewModel.angle.degrees += 90
              viewModel.lastAngle = viewModel.angle
            }
          } label: {
            Image(systemName: "rotate.right")
              .foregroundStyle(configuration.colors.rotateButton)
              .fontWeight(.semibold)
          }
          .padding()
        }
#if !os(visionOS)
        .glassEffect()
#endif
      }
      
      Spacer()
      
      Button {
        Task {
          isCropping = true
          defer { isCropping = false }
          await onComplete()
        }
      } label: {
        Image(systemName: "checkmark")
          .fontWeight(.semibold)
      }
      .padding()
      .disabled(isCropping)
#if !os(visionOS)
      .glassEffect(.regular.tint(configuration.colors.saveButton))
#endif
    }
    .frame(maxWidth: .infinity)
#else
    VStack {
      Text("iOS 26 is not supported. Adjust the simulator or your Xcode version.")
    }
    .border(.red)
#endif
  }
}
