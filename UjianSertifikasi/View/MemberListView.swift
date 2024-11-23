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
                            if editingMemberId == member.id {
                                // Editing Mode
                                TextField("Edit Member Name", text: $editedMemberName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                TextField("Edit Member Email", text: $editedMemberEmail)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                HStack {
                                    Button("Save") {
                                        validateAndEditMember(member: member)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    Button("Cancel") {
                                        editingMemberId = nil // Exit edit mode
                                    }
                                    .buttonStyle(.bordered)
                                }
                            } else {
                                // Display Mode
                                Text(member.name).font(.headline)
                                Text(member.email).font(.subheadline).foregroundColor(.gray)

                                HStack {
                                    Button("Edit") {
                                        startEditing(member: member)
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Delete") {
                                        Task {
                                            do {
                                                try await viewModel.deleteMember(id: member.id)
                                            } catch {
                                                generalErrorMessage = "Failed to delete member: \(error.localizedDescription)"
                                            }
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red)
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

    private func startEditing(member: Member) {
        editingMemberId = member.id
        editedMemberName = member.name
        editedMemberEmail = member.email
    }

    private func validateAndEditMember(member: Member) {
        guard !editedMemberName.isEmpty else {
            generalErrorMessage = "Member name cannot be empty."
            return
        }
        guard !editedMemberEmail.isEmpty else {
            generalErrorMessage = "Member email cannot be empty."
            return
        }

        Task {
            do {
                try await viewModel.editMember(id: member.id, name: editedMemberName, email: editedMemberEmail)
                generalErrorMessage = nil
                editingMemberId = nil // Exit edit mode
            } catch {
                generalErrorMessage = "Failed to edit member: \(error.localizedDescription)"
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
