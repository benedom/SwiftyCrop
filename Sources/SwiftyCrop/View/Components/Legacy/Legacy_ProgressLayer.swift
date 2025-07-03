import SwiftUI

struct Legacy_ProgressLayer: View {
  let configuration: SwiftyCropConfiguration
  let localizableTableName: String
  
  var body: some View {
    ZStack {
      configuration.colors.background.opacity(0.4)
        .ignoresSafeArea()
      
      VStack(alignment: .center, spacing: 5) {
        
        Spacer(minLength: 35)
        
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: configuration.colors.interactionInstructions))
          .scaleEffect(1.2)
        
        Spacer()
        
        Text(
          configuration.texts.progressLayerText ??
          NSLocalizedString("processing_label", tableName: localizableTableName, bundle: .module, comment: "")
        )
        .font(.body)
        .foregroundColor(configuration.colors.interactionInstructions)
        .padding(.bottom, 12)
        
      }
      .frame(width: 120, height: 110)
      .background(configuration.colors.background.opacity(0.8))
      .cornerRadius(12)
      .padding(.vertical, 5)
      .padding(.horizontal, 15)
    }
    .transition(.opacity)
  }
}
