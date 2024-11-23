//
//  BookListView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct BookListView: View {
    @StateObject private var viewModel = BookViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()

    @State private var selectedCategory: Category? = nil
    @State private var searchText: String = ""
    @State private var bookToEdit: Book? = nil
    @State private var isNavigatingToEdit = false

    var body: some View {
        NavigationView {
            VStack {
                // Category Filter
                Picker("Filter by Category", selection: $selectedCategory) {
                    Text("All Categories").tag(Category?.none) // No filter
                    ForEach(categoryViewModel.categories, id: \.id) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                // Book List
                List(filteredBooks) { book in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.headline)
                        Text(book.author)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(book.categories.map { "#\($0.name)" }.joined(separator: " "))
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .swipeActions {
                        // Delete Button
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await viewModel.deleteBook(id: book.id)
                                } catch {
                                    print("Failed to delete book: \(error.localizedDescription)")
                                }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        // Edit Button
                        Button {
                            print("Navigating to edit book: \(book.title)")
                            bookToEdit = book // Set the book to edit
                            isNavigatingToEdit = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }

                // Navigate to AddEditBookView
                NavigationLink(
                    destination: AddEditBookView(
                        isAdding: false,
                        book: bookToEdit ?? Book(id: 0, title: "", author: "", memberId: nil, categories: []),
                        onSave: { title, author, categoryIds in
                            Task {
                                do {
                                    print("Saving edited book: \(title)")
                                    try await viewModel.editBook(id: bookToEdit?.id ?? 0, title: title, author: author, categoryIds: categoryIds)
                                    try await viewModel.fetchBooks()
                                    isNavigatingToEdit = false // Return to the book list
                                } catch {
                                    print("Failed to edit book: \(error.localizedDescription)")
                                }
                            }
                        }
                    ),
                    isActive: $isNavigatingToEdit,
                    label: { EmptyView() }
                )
            }
            .navigationTitle("Books")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add") {
                        AddEditBookView(isAdding: true, book: nil) { title, author, categoryIds in
                            Task {
                                do {
                                    try await viewModel.addBook(title: title, author: author, categoryIds: categoryIds)
                                } catch {
                                    print("Failed to add book: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        try await viewModel.fetchBooks()
                        try await categoryViewModel.fetchCategories()
                    } catch {
                        print("Failed to load data: \(error.localizedDescription)")
                    }
                }
            }
            .searchable(text: $searchText)
        }
    }

    // Filter Books by Category
    private var filteredBooks: [Book] {
        let booksFilteredByCategory: [Book]
        if let selectedCategory = selectedCategory {
            booksFilteredByCategory = viewModel.books.filter { book in
                book.categories.contains(where: { $0.id == selectedCategory.id })
            }
        } else {
            booksFilteredByCategory = viewModel.books
        }

        if searchText.isEmpty {
            return booksFilteredByCategory
        } else {
            return booksFilteredByCategory.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock ViewModels
        let mockBookViewModel = BookViewModel()
        mockBookViewModel.books = [
            Book(id: 1, title: "Harry Potter", author: "J.K. Rowling", memberId: nil, categories: [
                Category(id: 1, name: "Fantasy"),
                Category(id: 2, name: "Adventure")
            ]),
            Book(id: 2, title: "The Hobbit", author: "J.R.R. Tolkien", memberId: nil, categories: [
                Category(id: 1, name: "Fantasy")
            ])
        ]

        let mockCategoryViewModel = CategoryViewModel()
        mockCategoryViewModel.categories = [
            Category(id: 1, name: "Fantasy"),
            Category(id: 2, name: "Adventure")
        ]

        return BookListView()
            .environmentObject(mockBookViewModel)
            .environmentObject(mockCategoryViewModel)
    }
}
