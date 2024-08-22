//
//  LocalStorage.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 19/08/24.
//

import Foundation

class LocalStorage {

    func setCurrentBooKId( bookId : Int){
        if let data = try? JSONEncoder().encode(bookId) {
            UserDefaults.standard.set(data, forKey: K.currentBookId)
        }
    }
    
    func getCurrentBookId() -> Int{
        if let data = UserDefaults.standard.data(forKey: K.currentBookId),
           let currentBookId = try? JSONDecoder().decode(Int.self, from: data) {
            return currentBookId + 1
        }
        return 0
    }
    
    func setFavoritesToLocalStorage(with favorites: [Int]){
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: K.favorites)
        }
    }
    
    func getFavoritesFromLocalStorage() -> [Int]?{
        if let data = UserDefaults.standard.data(forKey: K.favorites),
           let favorites = try? JSONDecoder().decode([Int].self, from: data) {
            return favorites
        }
        return []
    }
    
    func saveLocalBook(_ book: BookItem) {
        var localBooks = getLocalBooks()
        if localBooks.count > 0{
            localBooks.append(book)
            updateLocalBooks(with: localBooks)
        }else{
            var newBooks : [BookItem] = []
            newBooks.append(book)
            updateLocalBooks(with: newBooks)
        }
    }
    
    func deleteBook(for index: Int){
        var localBooks = getLocalBooks()
        if let idx = localBooks.firstIndex(where: { $0.id == index }) {
            localBooks.remove(at: idx)
        }
        updateLocalBooks(with: localBooks)
    }
    
    func getBook(for index: Int)-> BookItem?{
        let localBooks = getLocalBooks()
        if let idx = localBooks.firstIndex(where: { $0.id == index }) {
            return localBooks[idx]
        }
        return nil
    }
    
    func updateLocalBooks(with books: [BookItem]){
        if let data = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(data, forKey: K.localBooksKey)
        }
    }

    func getLocalBooks() -> [BookItem] {
        if let data = UserDefaults.standard.data(forKey: K.localBooksKey),
           let books = try? JSONDecoder().decode([BookItem].self, from: data) {
            return books
        }
        return []
    }
    
    func deleteAllLocalBooks(){
        if let data = UserDefaults.standard.data(forKey: K.localBooksKey),
           let _ = try? JSONDecoder().decode([BookItem].self, from: data) {
            UserDefaults.standard.removeObject(forKey: K.localBooksKey)
        }
    }
}
