import SwiftUI

struct Legacy_ButtonsView: View {
    let configuration: SwiftyCropConfiguration
    let localizableTableName: String
    let dismiss: () -> Void
    let onComplete: () async -> Void
    @State private var isCropping = false
  
  var body: some View {
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
          .disabled(isCropping)
          
          Spacer()
          
          Button {
              Task {
                  isCropping = true
                  await onComplete()
                  isCropping = false
              }
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
          .disabled(isCropping)
      }
      .frame(maxWidth: .infinity, alignment: .bottom)
  }
}
