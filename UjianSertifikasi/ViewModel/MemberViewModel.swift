//
//  MemberViewModel.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import Foundation

class MemberViewModel: ObservableObject {
    @Published var members: [Member] = []

    // Fetch all members
    func fetchMembers() async throws {
        let rows = try await DatabaseManager.shared.executeQuery("SELECT id, name, email FROM members")
        DispatchQueue.main.async {
            self.members = rows.compactMap { row in
                guard let id = row.column("id")?.int,
                      let name = row.column("name")?.string,
                      let email = row.column("email")?.string else { return nil }
                return Member(id: id, name: name, email: email)
            }
        }
    }

    // Add a new member
    func addMember(name: String, email: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("INSERT INTO members (name, email) VALUES ('\(name)', '\(email)')")
                try await fetchMembers()
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

    // Delete a member
    func deleteMember(id: Int) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("DELETE FROM members WHERE id = \(id)")
                try await fetchMembers()
            } catch {
                print("Failed to delete member: \(error)")
            }
        }
    }

    // Edit a member
    func editMember(id: Int, newName: String, newEmail: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await DatabaseManager.shared.executeQuery("UPDATE members SET name = '\(newName)', email = '\(newEmail)' WHERE id = \(id)")
                try await fetchMembers()
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
