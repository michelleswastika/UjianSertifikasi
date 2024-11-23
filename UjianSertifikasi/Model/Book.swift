//
//  Book.swift
//  UjianSertifikasi
//
//  Created by Michelle Swastika on 23/11/24.
//

struct Book: Identifiable {
    let id: Int
    let title: String
    let author: String
    let memberId: Int?
    var categories: [Category]
}
