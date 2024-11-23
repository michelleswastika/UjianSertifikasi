//
//  ContentView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView {
                // BookListView Tab
                BookListView()
                    .tabItem {
                        Label("Books", systemImage: "book.fill")
                    }

                // CategoryListView Tab
                CategoryListView()
                    .tabItem {
                        Label("Categories", systemImage: "tag.fill")
                    }

                // MemberListView Tab
                MemberListView()
                    .tabItem {
                        Label("Members", systemImage: "person.3.fill")
                    }
            }
            .accentColor(.blue)
        }
    }
}

#Preview {
    ContentView()
}
