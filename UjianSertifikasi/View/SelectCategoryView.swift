//
//  SelectCategoryView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct SelectCategoryView: View {
    @Binding var selectedCategories: [Category]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoryViewModel = CategoryViewModel()

    var body: some View {
        List {
            ForEach(categoryViewModel.categories) { category in
                HStack {
                    Text(category.name)
                    Spacer()
                    if selectedCategories.contains(where: { $0.id == category.id }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleCategorySelection(category)
                }
            }
        }
        .navigationBarTitle("Select Category", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    dismiss()
                }
            }
        }
        .onAppear {
            Task {
                do {
                    try await categoryViewModel.fetchCategories()
                } catch {
                    print("Failed to load categories: \(error.localizedDescription)")
                }
            }
        }
    }

    private func toggleCategorySelection(_ category: Category) {
        if let index = selectedCategories.firstIndex(where: { $0.id == category.id }) {
            selectedCategories.remove(at: index)
            print("Removed category: \(category.name), updated array: \(selectedCategories.map { $0.name })")
        } else {
            selectedCategories.append(category)
            print("Added category: \(category.name), updated array: \(selectedCategories.map { $0.name })")
        }
    }
}


struct SelectCategoryView_Previews: PreviewProvider {
    @State static var selectedCategories = [
        Category(id: 1, name: "Action"),
        Category(id: 2, name: "Adventure")
    ]

    static var previews: some View {
        SelectCategoryView(selectedCategories: $selectedCategories)
    }
}
