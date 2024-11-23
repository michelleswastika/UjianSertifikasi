//
//  RelationsViewModel.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import Foundation

class RelationsViewModel: ObservableObject {
    @Published var booksByCategory: [Book] = []
    @Published var borrowedBooksByMember: [Book] = []

    // Fetch books by category
    func fetchBooksByCategory(categoryId: Int) async throws {
        let rows = try await DatabaseManager.shared.executeQuery("""
            SELECT b.id, b.title, b.author, b.member_id
            FROM books b
            JOIN book_categories bc ON b.id = bc.book_id
            WHERE bc.category_id = \(categoryId)
        """)
        DispatchQueue.main.async {
            self.booksByCategory = rows.compactMap { row in
                guard let id = row.column("id")?.int,
                      let title = row.column("title")?.string,
                      let author = row.column("author")?.string else { return nil }
                return Book(id: id, title: title, author: author, memberId: row.column("member_id")?.int)
            }
        }
    }

    // Fetch books borrowed by member
    func fetchBooksByMember(memberId: Int) async throws {
        let rows = try await DatabaseManager.shared.executeQuery("""
            SELECT id, title, author, member_id
            FROM books
            WHERE member_id = \(memberId)
        """)
        DispatchQueue.main.async {
            self.borrowedBooksByMember = rows.compactMap { row in
                guard let id = row.column("id")?.int,
                      let title = row.column("title")?.string,
                      let author = row.column("author")?.string else { return nil }
                return Book(id: id, title: title, author: author, memberId: row.column("member_id")?.int)
            }
        }
    }
}
