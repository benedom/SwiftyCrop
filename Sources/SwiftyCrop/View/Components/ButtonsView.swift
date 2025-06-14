import SwiftUI

struct ButtonsView: View {
  let configuration: SwiftyCropConfiguration
  let localizableTableName: String
  let dismiss: () -> Void
  let onComplete: () -> Void
  
  var body: some View {
    VStack {
      Spacer()
        
      HStack {
        Button {
          dismiss()
        } label: {
          Text(
            configuration.texts.cancelButton ??
            NSLocalizedString("cancel_button", tableName: localizableTableName, bundle: .module, comment: "")
          )
          .padding()
          .font(configuration.fonts.cancelButton)
          .foregroundColor(configuration.colors.cancelButton)
        }
        .padding()
        
        Spacer()
        
        Button {
          onComplete()
        } label: {
          Text(
            configuration.texts.saveButton ??
            NSLocalizedString("save_button", tableName: localizableTableName, bundle: .module, comment: "")
          )
          .padding()
          .font(configuration.fonts.saveButton)
          .foregroundColor(configuration.colors.saveButton)
        }
        .padding()
      }
      .frame(maxWidth: .infinity, alignment: .bottom)
    }
  }
}
