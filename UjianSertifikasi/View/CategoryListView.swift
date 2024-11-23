//
//  CategoryListView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var newCategoryName: String = "" // For adding a new category
    @State private var editedCategoryName: String = "" // For editing a category
    @State private var editingCategoryId: Int? // Track the category being edited
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                List {
                    ForEach(viewModel.categories) { category in
                        HStack {
                            if editingCategoryId == category.id {
                                // Inline editing TextField
                                TextField("Edit Category", text: $editedCategoryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onSubmit {
                                        saveCategory(category: category)
                                    }
                                Spacer()
                                Button("Save") {
                                    saveCategory(category: category)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            } else {
                                // Static display with Edit button
                                Text(category.name)
                                Spacer()
                                Button("Edit") {
                                    startEditing(category: category)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let category = viewModel.categories[index]
                            viewModel.deleteCategory(id: category.id)
                        }
                    }
                }

                HStack {
                    TextField("New Category", text: $newCategoryName) // For adding categories
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        guard !newCategoryName.isEmpty else { return }
                        viewModel.addCategory(name: newCategoryName) { error in
                            if let error = error {
                                self.errorMessage = "Failed to add category: \(error.localizedDescription)"
                            } else {
                                self.errorMessage = nil
                            }
                        }
                        newCategoryName = ""
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
            .onAppear {
                Task {
                    do {
                        try await viewModel.fetchCategories()
                    } catch {
                        errorMessage = "Failed to load categories: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    // Start editing a category
    private func startEditing(category: Category) {
        editingCategoryId = category.id
        editedCategoryName = category.name // Initialize the edited name with the category's current name
    }

    // Save the edited category
    private func saveCategory(category: Category) {
        guard !editedCategoryName.isEmpty else {
            errorMessage = "Category name cannot be empty."
            return
        }
        viewModel.editCategory(id: category.id, newName: editedCategoryName) { error in
            if let error = error {
                self.errorMessage = "Failed to edit category: \(error.localizedDescription)"
            } else {
                self.errorMessage = nil
                editingCategoryId = nil // Exit edit mode
            }
        }
    }
}

#Preview {
    CategoryListView()
}
