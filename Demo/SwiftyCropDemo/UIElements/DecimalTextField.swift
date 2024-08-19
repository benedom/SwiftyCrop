import SwiftUI

struct DecimalTextField: View {
    @Binding var value: CGFloat
    private let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = true
        formatter.minimumFractionDigits = 1
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    var body: some View {
        TextField("maxMagnification", value: $value, formatter: decimalFormatter)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .multilineTextAlignment(.trailing)
            #if os(iOS)
            .keyboardType(.decimalPad)
            #endif
    }
}
