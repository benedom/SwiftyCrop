import SwiftUI

@available(iOS 26, *)
struct ToolbarView: View {
  @ObservedObject var viewModel: CropViewModel
  let configuration: SwiftyCropConfiguration
  let dismiss: () -> Void
  let onComplete: () async -> Void
  @State private var isCropping = false
  
  var body: some View {
    HStack {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .foregroundStyle(configuration.colors.cancelButton)
          .fontWeight(.semibold)
      }
      .padding()
      .glassEffect()
      
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
        .glassEffect()
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
        .glassEffect()
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
          .foregroundStyle(configuration.colors.saveButton)
          .fontWeight(.semibold)
      }
      .padding()
      .disabled(isCropping)
      .glassEffect(.regular.tint(Color.yellow))
    }
    .frame(maxWidth: .infinity)
  }
}
