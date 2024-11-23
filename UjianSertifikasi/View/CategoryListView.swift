//
//  CategoryListView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var newCategoryName: String = ""
    @State private var addErrorMessage: String?

    @State private var editingCategoryId: Int? // Track the category being edited
    @State private var editedCategoryName: String = ""
    @State private var editErrorMessage: String?

    @State private var generalErrorMessage: String? // General error messages for fetch or delete actions

    var body: some View {
        NavigationView {
            VStack {
                // General Error Messages
                if let generalErrorMessage = generalErrorMessage {
                    Text(generalErrorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                List {
                    ForEach(viewModel.categories) { category in
                        HStack {
                            if editingCategoryId == category.id {
                                // Inline editing mode
                                TextField("Edit Category", text: $editedCategoryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onSubmit {
                                        validateAndSaveCategory(category: category)
                                    }
                                if let editErrorMessage = editErrorMessage {
                                    Text(editErrorMessage)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Spacer()
                                Button("Save") {
                                    validateAndSaveCategory(category: category)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            } else {
                                // Normal display mode
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

                VStack {
                    // Add New Category Field
                    TextField("New Category Name", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if let addErrorMessage = addErrorMessage {
                        Text(addErrorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    Button("Add") {
                        validateAndAddCategory()
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
                        generalErrorMessage = "Failed to load categories: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    private func startEditing(category: Category) {
        editingCategoryId = category.id
        editedCategoryName = category.name
        editErrorMessage = nil // Clear any previous errors
    }

    private func validateAndSaveCategory(category: Category) {
        guard !editedCategoryName.isEmpty else {
            editErrorMessage = "Category name cannot be empty."
            return
        }
        viewModel.editCategory(id: category.id, newName: editedCategoryName) { error in
            if let error = error {
                generalErrorMessage = "Failed to edit category: \(error.localizedDescription)"
            } else {
                generalErrorMessage = nil
                editingCategoryId = nil // Exit edit mode
            }
        }
    }

    private func validateAndAddCategory() {
        guard !newCategoryName.isEmpty else {
            addErrorMessage = "Category name cannot be empty."
            return
        }
        viewModel.addCategory(name: newCategoryName) { error in
            if let error = error {
                generalErrorMessage = "Failed to add category: \(error.localizedDescription)"
            } else {
                generalErrorMessage = nil
                newCategoryName = ""
                addErrorMessage = nil // Clear any errors
            }
        }
    }
}

#Preview {
    CategoryListView()
}
