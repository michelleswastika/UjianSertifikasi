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
    @State private var editedCategoryName: String = ""
    @State private var editingCategoryId: Int? = nil
    @State private var addErrorMessage: String?
    @State private var editErrorMessage: String?
    @State private var generalErrorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if let generalErrorMessage = generalErrorMessage {
                    Text(generalErrorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                List {
                    ForEach(viewModel.categories) { category in
                        VStack(alignment: .leading) {
                            if editingCategoryId == category.id {
                                // Editing Mode
                                TextField("Edit Category Name", text: $editedCategoryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                if let errorMessage = editErrorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .font(.footnote)
                                }

                                HStack {
                                    Button("Save") {
                                        validateAndSaveCategory(category: category)
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Cancel") {
                                        editingCategoryId = nil // Exit edit mode
                                    }
                                    .buttonStyle(.bordered)
                                }
                            } else {
                                // Display Mode
                                Text(category.name).font(.headline)

                                HStack {
                                    Button("Edit") {
                                        startEditing(category: category)
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Delete") {
                                        Task {
                                            do {
                                                try await viewModel.deleteCategory(id: category.id)
                                            } catch {
                                                generalErrorMessage = "Failed to delete category: \(error.localizedDescription)"
                                            }
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red)
                                }
                            }
                        }
                    }
                }

                Divider()

                VStack {
                    if let addErrorMessage = addErrorMessage {
                        Text(addErrorMessage)
                            .foregroundColor(.red)
                    }

                    TextField("New Category Name", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Add Category") {
                        validateAndAddCategory()
                    }
                    .buttonStyle(.borderedProminent)
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
    }

    private func validateAndSaveCategory(category: Category) {
        guard !editedCategoryName.isEmpty else {
            editErrorMessage = "Category name cannot be empty."
            return
        }

        Task {
            do {
                try await viewModel.editCategory(id: category.id, newName: editedCategoryName)
                generalErrorMessage = nil
                editingCategoryId = nil // Exit edit mode
            } catch {
                generalErrorMessage = "Failed to edit category: \(error.localizedDescription)"
            }
        }
    }

    private func validateAndAddCategory() {
        guard !newCategoryName.isEmpty else {
            addErrorMessage = "Category name cannot be empty."
            return
        }

        Task {
            do {
                try await viewModel.addCategory(name: newCategoryName)
                generalErrorMessage = nil
                newCategoryName = ""
                addErrorMessage = nil // Clear any errors
            } catch {
                generalErrorMessage = "Failed to add category: \(error.localizedDescription)"
            }
        }
    }
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView()
    }
}
