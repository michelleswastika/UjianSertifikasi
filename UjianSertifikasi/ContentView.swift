//
//  ContentView.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Testing members fetch...")
            .onAppear {
                Task {
                    await DatabaseManager.shared.testFetchMembers()
                }
            }
            .onDisappear {
                Task {
                    await DatabaseManager.shared.closeConnection()
                }
            }
    }
}

#Preview {
    ContentView()
}
