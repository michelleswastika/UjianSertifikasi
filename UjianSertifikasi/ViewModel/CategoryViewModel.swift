//
//  CategoryViewModel.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []

    // Fetch categories
    func fetchCategories() async throws {
        let rows = try await DatabaseManager.shared.executeQuery("SELECT id, name FROM categories")
        DispatchQueue.main.async {
            self.categories = rows.compactMap { row in
                guard let id = row.column("id")?.int,
                      let name = row.column("name")?.string else { return nil }
                return Category(id: id, name: name)
            }
        }
    }

    // Add a new category
    func addCategory(name: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("INSERT INTO categories (name) VALUES ('\(name)')")
                try await fetchCategories()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    // Delete a category
    func deleteCategory(id: Int) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("DELETE FROM categories WHERE id = \(id)")
                try await fetchCategories()
            } catch {
                print("Failed to delete category: \(error)")
            }
        }
    }

    // Edit a category
    func editCategory(id: Int, newName: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("UPDATE categories SET name = '\(newName)' WHERE id = \(id)")
                try await fetchCategories()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}
