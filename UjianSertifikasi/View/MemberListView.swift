//
//  MemberListView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct MemberListView: View {
    @StateObject private var viewModel = MemberViewModel()
    @State private var newMemberName: String = ""
    @State private var newMemberEmail: String = ""
    @State private var editingMemberId: Int? = nil
    @State private var editedMemberName: String = ""
    @State private var editedMemberEmail: String = ""

    @State private var generalErrorMessage: String?
    @State private var addErrorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if let generalErrorMessage = generalErrorMessage {
                    Text(generalErrorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                List {
                    ForEach(viewModel.members) { member in
                        VStack(alignment: .leading) {
                            Text(member.name).font(.headline)
                            Text(member.email).font(.subheadline).foregroundColor(.gray)

                            // Navigation to Borrowed Books
                            NavigationLink(destination: BorrowedBooksView(member: member)) {
                                Text("View Borrowed Books")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle()) // To remove the default button style

                            // Edit and Delete Buttons
                            VStack(alignment: .leading) {
                                if editingMemberId == member.id {
                                    // Editing member in place
                                    TextField("Name", text: $editedMemberName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.top, 5)

                                    TextField("Email", text: $editedMemberEmail)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.top, 5)

                                    Button(action: {
                                        Task {
                                            do {
                                                // Save the changes
                                                try await viewModel.editMember(id: member.id, name: editedMemberName, email: editedMemberEmail)
                                                editingMemberId = nil // Close the editing mode
                                            } catch {
                                                print("Failed to edit member: \(error.localizedDescription)")
                                            }
                                        }
                                    }) {
                                        Text("Save Changes")
                                            .foregroundColor(.blue)
                                    }

                                    Button(action: {
                                        // Cancel the editing
                                        editingMemberId = nil
                                    }) {
                                        Text("Cancel")
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    // Default state - show Edit and Delete buttons
                                    HStack {
                                        Button(action: {
                                            // Set the current member in edit mode
                                            editingMemberId = member.id
                                            editedMemberName = member.name
                                            editedMemberEmail = member.email
                                        }) {
                                            Text("Edit")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                        Button(role: .destructive, action: {
                                            Task {
                                                do {
                                                    // Delete the member
                                                    try await viewModel.deleteMember(id: member.id)
                                                } catch {
                                                    print("Failed to delete member: \(error.localizedDescription)")
                                                }
                                            }
                                        }) {
                                            Text("Delete")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(.top, 5)
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

                    TextField("New Member Name", text: $newMemberName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("New Member Email", text: $newMemberEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add Member") {
                        validateAndAddMember()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Members")
            .onAppear {
                Task {
                    do {
                        try await viewModel.fetchMembers()
                    } catch {
                        generalErrorMessage = "Failed to load members: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    private func validateAndAddMember() {
        guard !newMemberName.isEmpty else {
            addErrorMessage = "Member name cannot be empty."
            return
        }
        guard !newMemberEmail.isEmpty else {
            addErrorMessage = "Member email cannot be empty."
            return
        }

        Task {
            do {
                try await viewModel.addMember(name: newMemberName, email: newMemberEmail)
                generalErrorMessage = nil
                newMemberName = ""
                newMemberEmail = ""
            } catch {
                generalErrorMessage = "Failed to add member: \(error.localizedDescription)"
            }
        }
    }
}

struct MemberListView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock Data for Preview
        let mockViewModel = MemberViewModel()
        mockViewModel.members = [
            Member(id: 1, name: "John Doe", email: "john.doe@example.com"),
            Member(id: 2, name: "Jane Smith", email: "jane.smith@example.com"),
        ]

        return MemberListView()
            .environmentObject(mockViewModel)
    }
}
