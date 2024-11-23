//
//  BookViewModel.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import Foundation

class BookViewModel: ObservableObject {
    @Published var books: [Book] = []

    // Fetch all books
    func fetchBooks() async throws {
        let rows = try await DatabaseManager.shared.executeQuery("""
            SELECT b.id, b.title, b.author, b.member_id, GROUP_CONCAT(c.id, ':', c.name) as categories
            FROM books b
            LEFT JOIN book_categories bc ON b.id = bc.book_id
            LEFT JOIN categories c ON bc.category_id = c.id
            GROUP BY b.id
        """)
        DispatchQueue.main.async {
            self.books = rows.compactMap { row in
                guard
                    let id = row.column("id")?.int,
                    let title = row.column("title")?.string,
                    let author = row.column("author")?.string
                else {
                    return nil
                }

                let categoryData = row.column("categories")?.string ?? ""
                let categories = categoryData.split(separator: ",").compactMap { categoryPair -> Category? in
                    let components = categoryPair.split(separator: ":")
                    guard components.count == 2,
                          let id = Int(components[0]) else { return nil }
                    return Category(id: id, name: String(components[1]))
                }

                return Book(id: id, title: title, author: author, memberId: row.column("member_id")?.int, categories: categories)
            }
        }
    }

    // Add a book
    func addBook(title: String, author: String, categoryIds: [Int]) async throws {
        // Insert the book
        let bookInsertQuery = """
        INSERT INTO books (title, author)
        VALUES ('\(title)', '\(author)')
        """
        try await DatabaseManager.shared.executeQuery(bookInsertQuery)

        // Get the ID of the inserted book
        let bookIdQuery = "SELECT LAST_INSERT_ID() AS id"
        let bookIdRows = try await DatabaseManager.shared.executeQuery(bookIdQuery)
        guard let bookId = bookIdRows.first?.column("id")?.int else {
            throw NSError(domain: "BookViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve book ID"])
        }

        // Link the book with its categories
        for categoryId in categoryIds {
            let categoryLinkQuery = """
            INSERT INTO book_categories (book_id, category_id)
            VALUES (\(bookId), \(categoryId))
            """
            try await DatabaseManager.shared.executeQuery(categoryLinkQuery)
        }

        // Refresh the books list
        try await fetchBooks()
    }

    // Edit book
    func editBook(id: Int, title: String, author: String, categoryIds: [Int]) async throws {
        // Update the book
        let updateQuery = """
        UPDATE books
        SET title = '\(title)', author = '\(author)'
        WHERE id = \(id)
        """
        try await DatabaseManager.shared.executeQuery(updateQuery)

        // Remove existing category links
        let deleteCategoriesQuery = "DELETE FROM book_categories WHERE book_id = \(id)"
        try await DatabaseManager.shared.executeQuery(deleteCategoriesQuery)

        // Add new category links
        for categoryId in categoryIds {
            let insertCategoryQuery = """
            INSERT INTO book_categories (book_id, category_id)
            VALUES (\(id), \(categoryId))
            """
            try await DatabaseManager.shared.executeQuery(insertCategoryQuery)
        }

        // Refresh the books list
        try await fetchBooks()
    }

    // Delete book
    func deleteBook(id: Int) async throws {
        let query = "DELETE FROM books WHERE id = \(id)"
        try await DatabaseManager.shared.executeQuery(query)
        try await fetchBooks() // Refresh books after deletion
    }
}
