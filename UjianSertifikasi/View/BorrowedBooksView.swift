//
//  BorrowedBooksView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 24/11/24.
//

import SwiftUI

struct BorrowedBooksView: View {
    var member: Member
    @StateObject private var relationsViewModel = RelationsViewModel()

    var body: some View {
        VStack {
            List(relationsViewModel.booksByMember) { book in
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.headline)
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                Task {
                    do {
                        try await relationsViewModel.fetchBooksByMember(memberId: member.id)
                    } catch {
                        print("Failed to fetch borrowed books: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationTitle("Borrowed Books")
        .toolbarTitleDisplayMode(.inline)
    }
}

struct BorrowedBooksView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMember = Member(id: 1, name: "John Doe", email: "john.doe@example.com")
        
        let mockBooks = [
            Book(id: 1, title: "Harry Potter", author: "J.K. Rowling", memberId: 1, categories: [
                Category(id: 1, name: "Fantasy"),
                Category(id: 2, name: "Adventure")
            ]),
            Book(id: 2, title: "The Hobbit", author: "J.R.R. Tolkien", memberId: 1, categories: [
                Category(id: 1, name: "Fantasy")
            ])
        ]

        let mockViewModel = RelationsViewModel()
        mockViewModel.booksByMember = mockBooks

        return BorrowedBooksView(member: mockMember)
            .environmentObject(mockViewModel)
    }
}
