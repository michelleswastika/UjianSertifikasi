//
//  MultiSelectPicker.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct MultiSelectPicker: View {
    let items: [(Int, String)]
    @Binding var selectedItems: Set<Int>

    var body: some View {
        VStack {
            ForEach(items, id: \.0) { item in
                HStack {
                    Text(item.1)
                    Spacer()
                    if selectedItems.contains(item.0) {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    if selectedItems.contains(item.0) {
                        selectedItems.remove(item.0)
                    } else {
                        selectedItems.insert(item.0)
                    }
                }
            }
        }
    }
}
