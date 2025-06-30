import SwiftUI

@available(iOS 26, *)
struct ProgressLayer: View {
  let configuration: SwiftyCropConfiguration
  let localizableTableName: String
  @State private var showAlert = true
  
  var body: some View {
#if compiler(>=6.2) // Use this to prevent compiling of unavailable iOS 26 APIs
    ZStack {
      configuration.colors.background.opacity(0.4)
        .ignoresSafeArea()
      
      VStack(alignment: .center, spacing: 20) {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: configuration.colors.interactionInstructions))
          .scaleEffect(1.2)
        
        Text(
          configuration.texts.progressLayerText ??
          NSLocalizedString("processing_label", tableName: localizableTableName, bundle: .module, comment: "")
        )
        .font(.body)
        .foregroundColor(configuration.colors.interactionInstructions)
      }
      .padding(25)
      .glassEffect(
        .regular.tint(configuration.colors.background.opacity(0.8)),
        in: .rect(cornerRadius: 12)
      )
      .padding(.vertical, 5)
      .padding(.horizontal, 20)
    }
    .transition(.opacity)
#else
    VStack {
      Text("iOS 26 is not supported. Adjust the simulator or your Xcode version.")
    }
    .border(.red)
#endif
  }
}

@available(iOS 26, *)
#Preview {
  ProgressLayer(configuration: .init(), localizableTableName: "Localizable")
}
