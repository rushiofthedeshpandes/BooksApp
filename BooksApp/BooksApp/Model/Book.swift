//
//  Book.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 19/08/24.
//
// MARK: - Book
import Foundation

class Book : Codable, Identifiable{
    var id: Int = 0
    var title: String = ""
    var author: String = ""
    var description: String = ""
    var cover: String = ""
    var publicationDate: String = ""
}

class BookItem: Book{
    var isFavorite : Bool = false
}



