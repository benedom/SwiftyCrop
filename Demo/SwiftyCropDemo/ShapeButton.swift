//
//  ShapeButton.swift
//  SwiftyCropDemo
//
//  Created by Leonid Zolotarev on 1/24/24.
//

import SwiftUI
import SwiftyCrop

struct ShapeButton: View {
    let title: String
    let shape: MaskShape
    @Binding var selection: MaskShape

    var body: some View {
        Button {
            selection = shape
        } label: {
            LongText(title: title)
        }
        .foregroundColor(selection == shape ? .accentColor : .secondary)
    }
}

#Preview {
    ShapeButton(
        title: "title",
        shape: .circle,
        selection: .constant(.circle)
    )
}
