import SwiftUI

struct RotateButtonsView: View {
    @ObservedObject var viewModel: CropViewModel
    let configuration: SwiftyCropConfiguration
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    viewModel.angle.degrees -= 90
                    viewModel.lastAngle = viewModel.angle
                }
            } label: {
                Image(systemName: "rotate.left")
                    .foregroundStyle(configuration.colors.rotateButton)
                    .padding()
            }
            .padding()
            
            Spacer()
            
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
                    .opacity(viewModel.angle.degrees.truncatingRemainder(dividingBy: 360) == 0 ? 0.3 : 1)
                    .padding()
            }
            .padding()
            .disabled(viewModel.angle.degrees.truncatingRemainder(dividingBy: 360) == 0)
            
            Spacer()
            
            Button {
                withAnimation {
                    viewModel.angle.degrees += 90
                    viewModel.lastAngle = viewModel.angle
                }
            } label: {
                Image(systemName: "rotate.right")
                    .foregroundStyle(configuration.colors.rotateButton)
                    .padding()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
}
