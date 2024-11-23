//
//  RelationsViewModel.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import Foundation

class RelationsViewModel: ObservableObject {
    @Published var booksByCategory: [Book] = []
    @Published var booksByMember: [Book] = []
    
    // Fetch books by category
    func fetchBooksByCategory(categoryId: Int) async throws {
        let rows = try await DatabaseManager.shared.executeQuery("""
            SELECT 
                b.id, b.title, b.author, b.member_id,
                c.id AS category_id, c.name AS category_name
            FROM books b
            LEFT JOIN book_categories bc ON b.id = bc.book_id
            LEFT JOIN categories c ON bc.category_id = c.id
            WHERE bc.category_id = \(categoryId)
        """)
        
        DispatchQueue.main.async {
            var bookDict: [Int: Book] = [:]
            
            for row in rows {
                guard
                    let id = row.column("id")?.int,
                    let title = row.column("title")?.string,
                    let author = row.column("author")?.string
                else { continue }
                
                let memberId = row.column("member_id")?.int
                let categoryId = row.column("category_id")?.int
                let categoryName = row.column("category_name")?.string
                
                if bookDict[id] == nil {
                    bookDict[id] = Book(
                        id: id,
                        title: title,
                        author: author,
                        memberId: memberId,
                        categories: []
                    )
                }
                
                if let categoryId = categoryId, let categoryName = categoryName {
                    let category = Category(id: categoryId, name: categoryName)
                    bookDict[id]?.categories.append(category)
                }
            }
            
            self.booksByCategory = Array(bookDict.values)
        }
    }
    
    func fetchBooksByMember(memberId: Int) async throws {
        let rows = try await DatabaseManager.shared.executeQuery("""
                SELECT 
                    b.id, b.title, b.author, b.member_id,
                    c.id AS category_id, c.name AS category_name
                FROM books b
                LEFT JOIN book_categories bc ON b.id = bc.book_id
                LEFT JOIN categories c ON bc.category_id = c.id
                WHERE b.member_id = \(memberId)
            """)
        
        DispatchQueue.main.async {
            var bookDict: [Int: Book] = [:]
            
            for row in rows {
                guard
                    let id = row.column("id")?.int,
                    let title = row.column("title")?.string,
                    let author = row.column("author")?.string
                else { continue }
                
                let memberId = row.column("member_id")?.int
                let categoryId = row.column("category_id")?.int
                let categoryName = row.column("category_name")?.string
                
                // Create a book object if not already created
                if bookDict[id] == nil {
                    bookDict[id] = Book(
                        id: id,
                        title: title,
                        author: author,
                        memberId: memberId,
                        categories: []
                    )
                }
                
                // Add category to the book
                if let categoryId = categoryId, let categoryName = categoryName {
                    let category = Category(id: categoryId, name: categoryName)
                    bookDict[id]?.categories.append(category)
                }
            }
            
            // Update the list of books by the member
            self.booksByMember = Array(bookDict.values)
        }
    }
}
