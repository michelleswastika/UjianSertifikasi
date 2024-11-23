//
//  CategoryViewModel.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []

    // Fetch all categories
    func fetchCategories() async throws {
        let rows = try await DatabaseManager.shared.executeQuery("SELECT id, name FROM categories ORDER BY name")
        DispatchQueue.main.async {
            self.categories = rows.compactMap { row in
                guard let id = row.column("id")?.int, let name = row.column("name")?.string else {
                    return nil
                }
                return Category(id: id, name: name)
            }
        }
    }

    // Add a category
    func addCategory(name: String) async throws {
        let insertQuery = "INSERT INTO categories (name) VALUES ('\(name)')"
        try await DatabaseManager.shared.executeQuery(insertQuery)
        try await fetchCategories() // Refresh the categories list
    }

    // Edit a category
    func editCategory(id: Int, newName: String) async throws {
        let updateQuery = "UPDATE categories SET name = '\(newName)' WHERE id = \(id)"
        try await DatabaseManager.shared.executeQuery(updateQuery)
        try await fetchCategories() // Refresh the categories list
    }

    // Delete a category
    func deleteCategory(id: Int) async throws {
        let deleteQuery = "DELETE FROM categories WHERE id = \(id)"
        try await DatabaseManager.shared.executeQuery(deleteQuery)
        try await fetchCategories() // Refresh the categories list
    }
}
