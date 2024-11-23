//
//  AddEditBookView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct AddEditBookView: View {
    let isAdding: Bool
    let book: Book?
    let onSave: (String, String, [Int]) -> Void

    @State private var title: String = ""
    @State private var author: String = ""
    @State private var selectedCategories: [Category] = []
    @Environment(\.dismiss) private var dismiss
    @State private var isInitialized = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("BOOK DETAILS")) {
                    TextField("Insert Book Title", text: $title)
                    TextField("Insert Book Author", text: $author)
                }

                Section(header: Text("CATEGORY")) {
                    if !selectedCategories.isEmpty {
                        Text(selectedCategories.map { "#\($0.name)" }.joined(separator: " "))
                            .font(.footnote)
                            .foregroundColor(.blue)
                    } else {
                        Text("No categories selected")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }

                    NavigationLink("Add Book Category") {
                        SelectCategoryView(selectedCategories: $selectedCategories)
                    }
                }
            }
        }
        .navigationBarTitle(isAdding ? "Add Book" : "Edit Book", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveBook()
                }
                .disabled(title.isEmpty || author.isEmpty || selectedCategories.isEmpty)
            }
        }
        .onAppear {
            if !isInitialized, let book = book { // Initialize only once
                print("Editing book: \(book.title), categories: \(book.categories.map { $0.name })")
                title = book.title
                author = book.author
                selectedCategories = book.categories
                isInitialized = true
            }
        }
        .onChange(of: selectedCategories) { newValue in
            print("Selected categories updated in AddEditBookView: \(newValue.map { $0.name })")
        }
    }

    private func saveBook() {
        let categoryIds = selectedCategories.map { $0.id }
        print("Saving book with categories: \(selectedCategories.map { $0.name })")
        onSave(title, author, categoryIds)
        dismiss()
    }
}

struct AddEditBookView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddEditBookView(
                isAdding: true,
                book: nil,
                onSave: { title, author, categoryIds in
                    print("Saved Book: \(title), \(author), Categories: \(categoryIds)")
                }
            )

            AddEditBookView(
                isAdding: false,
                book: Book(
                    id: 1,
                    title: "Harry Potter",
                    author: "J.K. Rowling",
                    memberId: nil,
                    categories: [
                        Category(id: 1, name: "Fantasy"),
                        Category(id: 2, name: "Adventure")
                    ]
                ),
                onSave: { title, author, categoryIds in
                    print("Updated Book: \(title), \(author), Categories: \(categoryIds)")
                }
            )
        }
    }
}
