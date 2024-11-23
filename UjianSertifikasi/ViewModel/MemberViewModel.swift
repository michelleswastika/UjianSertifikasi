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
        let rows = try await DatabaseManager.shared.executeQuery("SELECT id, name, email FROM members ORDER BY name")
        DispatchQueue.main.async {
            self.members = rows.compactMap { row in
                guard let id = row.column("id")?.int, let name = row.column("name")?.string, let email = row.column("email")?.string else {
                    return nil
                }
                return Member(id: id, name: name, email: email)
            }
        }
    }

    // Add a member
    func addMember(name: String, email: String) {
        Task {
            do {
                let insertMemberQuery = "INSERT INTO members (name, email) VALUES ('\(name)', '\(email)')"
                try await DatabaseManager.shared.executeQuery(insertMemberQuery)
                try await fetchMembers()
            } catch {
                print("Error adding member: \(error)")
            }
        }
    }

    // Edit a member
    func editMember(id: Int, name: String, email: String) {
        Task {
            do {
                let updateMemberQuery = "UPDATE members SET name = '\(name)', email = '\(email)' WHERE id = \(id)"
                try await DatabaseManager.shared.executeQuery(updateMemberQuery)
                try await fetchMembers()
            } catch {
                print("Error editing member: \(error)")
            }
        }
    }

    // Delete a member
    func deleteMember(id: Int) {
        Task {
            do {
                let deleteMemberQuery = "DELETE FROM members WHERE id = \(id)"
                try await DatabaseManager.shared.executeQuery(deleteMemberQuery)
                try await fetchMembers()
            } catch {
                print("Error deleting member: \(error)")
            }
        }
    }
}
