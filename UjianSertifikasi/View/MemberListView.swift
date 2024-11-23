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
    @State private var addErrorMessage: String?

    @State private var editingMemberId: Int? // Track the member being edited
    @State private var editedMemberName: String = ""
    @State private var editedMemberEmail: String = ""
    @State private var editErrorMessage: String?

    @State private var generalErrorMessage: String? // General error messages for fetch or delete actions

    var body: some View {
        NavigationView {
            VStack {
                // General Error Messages
                if let generalErrorMessage = generalErrorMessage {
                    Text(generalErrorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                List {
                    ForEach(viewModel.members) { member in
                        HStack {
                            if editingMemberId == member.id {
                                VStack(alignment: .leading) {
                                    TextField("Edit Name", text: $editedMemberName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    TextField("Edit Email", text: $editedMemberEmail)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    if let editErrorMessage = editErrorMessage {
                                        Text(editErrorMessage)
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Button("Save") {
                                    validateAndSaveMember(member: member)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            } else {
                                VStack(alignment: .leading) {
                                    Text(member.name)
                                    Text(member.email)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button("Edit") {
                                    startEditing(member: member)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let member = viewModel.members[index]
                            viewModel.deleteMember(id: member.id)
                        }
                    }
                }

                VStack {
                    // Add New Member Fields
                    TextField("New Member Name", text: $newMemberName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("New Member Email", text: $newMemberEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if let addErrorMessage = addErrorMessage {
                        Text(addErrorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    Button("Add") {
                        validateAndAddMember()
                    }
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
        editErrorMessage = nil // Clear any previous errors
    }

    private func validateAndSaveMember(member: Member) {
        guard !editedMemberName.isEmpty else {
            editErrorMessage = "Member name cannot be empty."
            return
        }
        guard !editedMemberEmail.isEmpty else {
            editErrorMessage = "Member email cannot be empty."
            return
        }
        viewModel.editMember(id: member.id, newName: editedMemberName, newEmail: editedMemberEmail) { error in
            if let error = error {
                generalErrorMessage = "Failed to edit member: \(error.localizedDescription)"
            } else {
                generalErrorMessage = nil
                editingMemberId = nil // Exit edit mode
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
        viewModel.addMember(name: newMemberName, email: newMemberEmail) { error in
            if let error = error {
                generalErrorMessage = "Failed to add member: \(error.localizedDescription)"
            } else {
                generalErrorMessage = nil
                newMemberName = ""
                newMemberEmail = ""
                addErrorMessage = nil // Clear any errors
            }
        }
    }
}

#Preview {
    MemberListView()
}
