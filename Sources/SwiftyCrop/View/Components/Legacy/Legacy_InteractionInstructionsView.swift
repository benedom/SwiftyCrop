import SwiftUI

struct Legacy_InteractionInstructionsView: View {
  let configuration: SwiftyCropConfiguration
  let localizableTableName: String
  
  var body: some View {
    Text(
      configuration.texts.interactionInstructions ??
      NSLocalizedString("interaction_instructions", tableName: localizableTableName, bundle: .module, comment: "")
    )
    .font(configuration.fonts.interactionInstructions)
    .foregroundColor(configuration.colors.interactionInstructions)
  }
}
