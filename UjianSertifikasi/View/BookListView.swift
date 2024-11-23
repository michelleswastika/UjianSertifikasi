//
//  BookListView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct BookListView: View {
    @StateObject private var viewModel = BookViewModel()
    
    // State for adding a book
    @State private var newBookTitle: String = ""
    @State private var newBookAuthor: String = ""
    @State private var addErrorMessage: String?

    // State for editing a book
    @State private var editingBookId: Int? // Track the book being edited
    @State private var editedBookTitle: String = ""
    @State private var editedBookAuthor: String = ""
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
                    ForEach(viewModel.books) { book in
                        HStack {
                            if editingBookId == book.id {
                                // Inline editing mode
                                VStack(alignment: .leading) {
                                    TextField("Edit Title", text: $editedBookTitle)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    TextField("Edit Author", text: $editedBookAuthor)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    if let editErrorMessage = editErrorMessage {
                                        Text(editErrorMessage)
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Button("Save") {
                                    validateAndSaveBook(book: book)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            } else {
                                // Normal display mode
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                        .font(.headline)
                                    Text(book.author)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button("Edit") {
                                    startEditing(book: book)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let book = viewModel.books[index]
                            viewModel.deleteBook(id: book.id)
                        }
                    }
                }

                VStack {
                    // Add New Book Fields
                    TextField("New Book Title", text: $newBookTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("New Book Author", text: $newBookAuthor)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if let addErrorMessage = addErrorMessage {
                        Text(addErrorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    Button("Add") {
                        validateAndAddBook()
                    }
                }
                .padding()
            }
            .navigationTitle("Books")
            .onAppear {
                Task {
                    do {
                        try await viewModel.fetchBooks()
                    } catch {
                        generalErrorMessage = "Failed to load books: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    // Start editing a book
    private func startEditing(book: Book) {
        editingBookId = book.id
        editedBookTitle = book.title
        editedBookAuthor = book.author
        editErrorMessage = nil // Clear any previous errors
    }

    // Validate and save the edited book
    private func validateAndSaveBook(book: Book) {
        guard !editedBookTitle.isEmpty else {
            editErrorMessage = "Book title cannot be empty."
            return
        }
        guard !editedBookAuthor.isEmpty else {
            editErrorMessage = "Book author cannot be empty."
            return
        }
        viewModel.editBook(id: book.id, newTitle: editedBookTitle, newAuthor: editedBookAuthor) { error in
            if let error = error {
                generalErrorMessage = "Failed to edit book: \(error.localizedDescription)"
            } else {
                generalErrorMessage = nil
                editingBookId = nil // Exit edit mode
            }
        }
    }

    // Validate and add a new book
    private func validateAndAddBook() {
        guard !newBookTitle.isEmpty else {
            addErrorMessage = "Book title cannot be empty."
            return
        }
        guard !newBookAuthor.isEmpty else {
            addErrorMessage = "Book author cannot be empty."
            return
        }
        viewModel.addBook(title: newBookTitle, author: newBookAuthor) { error in
            if let error = error {
                generalErrorMessage = "Failed to add book: \(error.localizedDescription)"
            } else {
                generalErrorMessage = nil
                newBookTitle = ""
                newBookAuthor = ""
                addErrorMessage = nil // Clear any errors
            }
        }
    }
}

#Preview {
    BookListView()
}
