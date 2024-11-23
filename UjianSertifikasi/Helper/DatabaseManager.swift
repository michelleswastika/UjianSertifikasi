//
//  DatabaseManager.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import MySQLNIO
import NIOCore
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var connection: MySQLConnection?
    
    init() {}
    
    private func initializeConnection() async throws {
        if connection == nil {
            let futureConnection = MySQLConnection.connect(
                to: try SocketAddress(ipAddress: "127.0.0.1", port: 3306),
                username: "root",
                database: "LibraryDB",
                password: "",
                tlsConfiguration: .forClient(),
                on: self.eventLoopGroup.next()
            )
            self.connection = try await futureConnection.get()
            print("Successfully connected to the MySQL database!")
        }
    }
    
    func executeQuery(_ query: String) async throws -> [MySQLRow] {
        try await initializeConnection()
        guard let connection = connection else {
            throw NSError(domain: "DatabaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database connection not initialized."])
        }
        return try await connection.query(query).get()
    }
    
    func closeConnection() async {
        if let connection = connection {
            do {
                try await connection.close()
                print("Database connection closed.")
            } catch {
                print("Failed to close database connection: \(error)")
            }
        }
    }
    
    deinit {
        Task {
            await closeConnection()
            do {
                try self.eventLoopGroup.syncShutdownGracefully()
            } catch {
                print("Failed to shut down event loop group: \(error)")
            }
        }
    }
}

extension DatabaseManager {
    func testFetchMembers() async {
        do {
            let members = try await fetchMembers()
            for member in members {
                print("Member ID: \(member.id), Name: \(member.name), Email: \(member.email)")
            }
        } catch {
            print("Failed to fetch members: \(error)")
        }
    }
}

extension DatabaseManager {
    func fetchCategories() async throws -> [Category] {
        let rows = try await executeQuery("SELECT id, name FROM categories")
        return rows.compactMap { row in
            guard let id = row.column("id")?.int,
                  let name = row.column("name")?.string else { return nil }
            return Category(id: id, name: name)
        }
    }
    
    func addCategory(name: String) async throws {
        let query = "INSERT INTO categories (name) VALUES ('\(name)')"
        _ = try await executeQuery(query)
    }
    
    func updateCategory(id: Int, name: String) async throws {
        let query = "UPDATE categories SET name = '\(name)' WHERE id = \(id)"
        _ = try await executeQuery(query)
    }
    
    func deleteCategory(id: Int) async throws {
        let query = "DELETE FROM categories WHERE id = \(id)"
        _ = try await executeQuery(query)
    }
}

extension DatabaseManager {
    func fetchBooks() async throws -> [Book] {
        let rows = try await executeQuery("SELECT id, title, author, member_id FROM books")
        
        return rows.compactMap { row in
            guard
                let id = row.column("id")?.int,
                let title = row.column("title")?.string,
                let author = row.column("author")?.string
            else {
                return nil
            }
            
            let memberId = row.column("member_id")?.int // Optional
            return Book(id: id, title: title, author: author, memberId: memberId, categories: [])
        }
    }
    
    func addBook(title: String, author: String, memberId: Int?) async throws {
        let memberIdValue = memberId == nil ? "NULL" : "\(memberId!)"
        let query = "INSERT INTO books (title, author, member_id) VALUES ('\(title)', '\(author)', \(memberIdValue))"
        _ = try await executeQuery(query)
    }
    
    func updateBook(id: Int, title: String, author: String, memberId: Int?) async throws {
        let memberIdValue = memberId == nil ? "NULL" : "\(memberId!)"
        let query = "UPDATE books SET title = '\(title)', author = '\(author)', member_id = \(memberIdValue) WHERE id = \(id)"
        _ = try await executeQuery(query)
    }
    
    func deleteBook(id: Int) async throws {
        let query = "DELETE FROM books WHERE id = \(id)"
        _ = try await executeQuery(query)
    }
}

extension DatabaseManager {
    func fetchMembers() async throws -> [Member] {
        let rows = try await executeQuery("SELECT id, name, email FROM members")
        return rows.compactMap { row in
            guard let id = row.column("id")?.int,
                  let name = row.column("name")?.string,
                  let email = row.column("email")?.string else { return nil }
            return Member(id: id, name: name, email: email)
        }
    }
    
    func addMember(name: String, email: String) async throws {
        let query = "INSERT INTO members (name, email) VALUES ('\(name)', '\(email)')"
        _ = try await executeQuery(query)
    }
    
    func updateMember(id: Int, name: String, email: String) async throws {
        let query = "UPDATE members SET name = '\(name)', email = '\(email)' WHERE id = \(id)"
        _ = try await executeQuery(query)
    }
    
    func deleteMember(id: Int) async throws {
        let query = "DELETE FROM members WHERE id = \(id)"
        _ = try await executeQuery(query)
    }
}
