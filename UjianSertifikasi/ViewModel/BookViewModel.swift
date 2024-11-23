//
//  BookViewModel.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import Foundation

class BookViewModel: ObservableObject {
    @Published var books: [Book] = []

    func fetchBooks() async throws {
        let rows = try await DatabaseManager.shared.executeQuery("SELECT id, title, author, member_id FROM books")
        DispatchQueue.main.async {
            self.books = rows.compactMap { row in
                guard let id = row.column("id")?.int,
                      let title = row.column("title")?.string,
                      let author = row.column("author")?.string else { return nil }
                return Book(id: id, title: title, author: author, memberId: row.column("member_id")?.int)
            }
        }
    }

    func addBook(title: String, author: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("INSERT INTO books (title, author) VALUES ('\(title)', '\(author)')")
                try await fetchBooks()
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

    func deleteBook(id: Int) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("DELETE FROM books WHERE id = \(id)")
                try await fetchBooks()
            } catch {
                print("Failed to delete book: \(error)")
            }
        }
    }

    func editBook(id: Int, newTitle: String, newAuthor: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("UPDATE books SET title = '\(newTitle)', author = '\(newAuthor)' WHERE id = \(id)")
                try await fetchBooks()
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
