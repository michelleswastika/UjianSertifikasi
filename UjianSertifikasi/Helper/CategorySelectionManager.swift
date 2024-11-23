//
//  CategorySelectionManager.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 24/11/24.
//

import Foundation
import SwiftUI

class CategorySelectionManager: ObservableObject {
    @Published var selectedCategories: [Category] = []

    func toggleCategory(_ category: Category) {
        if let index = selectedCategories.firstIndex(where: { $0.id == category.id }) {
            selectedCategories.remove(at: index)
        } else {
            selectedCategories.append(category)
        }
    }

    func isSelected(_ category: Category) -> Bool {
        return selectedCategories.contains(where: { $0.id == category.id })
    }
}
