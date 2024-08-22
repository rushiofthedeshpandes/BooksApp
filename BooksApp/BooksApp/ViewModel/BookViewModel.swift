//
//  BookViewModel.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 19/08/24.
//

import Foundation
import Combine


class BooksViewModel: ObservableObject {
    @Published var totalBooks : [BookItem] = []
    @Published var books: [Book] = []
    @Published var error: Error?
    var cancellables: Set<AnyCancellable> = []
    
    // Dependency Injection
    private let apiManager: APIManagerService?
    private let endpoint: Endpoint
    private let storage : LocalStorage
    
    var bookSubject = PassthroughSubject<[BookItem], Error>()
    var bookDetailSubject = PassthroughSubject<Book, Error>()
    
    init(apiManager: APIManagerService?, endpoint: Endpoint, storage: LocalStorage) {
        self.apiManager = apiManager
        self.endpoint = endpoint
        self.storage = storage
    }
    
    private var currentPage: Int = 1
    var isLoading: Bool = false
    
    func fetchBooks() {
        let url = URL(string: endpoint.urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = K.HTTP_GET
        request.setValue(
            K.application_json,
            forHTTPHeaderField: K.content_type
        )
        guard !isLoading else { return }
        isLoading = true
        apiManager?.performRequest(request: request) { [weak self] (result: Result<[Book], Error>) in
            self?.isLoading = false
            switch result {
            case .success(let books):
                let items = Helper.shared.convertToItems(books)
                self?.totalBooks = items + (self?.storage.getLocalBooks() ?? [])
                self?.bookSubject.send(self?.totalBooks ?? [])
            case .failure(let error):
                self?.bookSubject.send(completion: .failure(error))
            }
        }
    }
    
    func fetchBookDetails(for bookId: String) {
        let url = URL(string: "\(endpoint.urlString)/\(bookId)")
        var request = URLRequest(url: url!)
        request.httpMethod = K.HTTP_GET
        request.setValue(
            K.application_json,
            forHTTPHeaderField: K.content_type
        )
        guard !isLoading else { return }
        isLoading = true
        apiManager?.performRequest(request: request) { [weak self] (result: Result<Book, Error>) in
            self?.isLoading = false
            switch result {
            case .success(let book):
                let bookItem = Helper.shared.convertToBookItem(book) as BookItem
                self?.bookDetailSubject.send(bookItem)
            case .failure(let error):
                let intBookId = Int(bookId)!
                guard let book = self?.storage.getBook(for: intBookId) else{
                    self?.bookDetailSubject.send(completion: .failure(error))
                    return
                }
                self?.bookDetailSubject.send(book)
                
            }
        }
    }
    
}

extension BooksViewModel{

    func toggleFavorite(_ bookId: Int){
        if  let favorites = storage.getFavoritesFromLocalStorage(), favorites.count > 0{
            var newFavorites = favorites
            if !newFavorites.contains(bookId){
                newFavorites.append(bookId)
            }else {
                if let index = newFavorites.firstIndex(of: bookId) {
                    newFavorites.remove(at: index)
                }
            }
            storage.setFavoritesToLocalStorage(with: newFavorites)
        }
        else{
            var favorites : [Int] = []
            favorites.append(bookId)
            storage.setFavoritesToLocalStorage(with: favorites)
        }
    }
    
    func getFavorites() -> [Int]{
        if let favorites = storage.getFavoritesFromLocalStorage(){
            return favorites
        }
        return []
    }
    
    func loadLocalBooks() -> [BookItem] {
        return storage.getLocalBooks()
    }

    func addCustomBook(book: BookItem) {
        storage.saveLocalBook(book)
    }

    func deleteCustomBook(for bookId: Int) {
        storage.deleteBook(for: bookId)
    }
    
    func deleteAllLocalBooks(){
        storage.deleteAllLocalBooks()
    }
    
    func getCustomBook(for bookId: Int) -> BookItem?{
        return storage.getBook(for: bookId) ?? nil
    }
    
    func getCustomBookId() -> Int{
        let currentBookId = storage.getCurrentBookId()
        if currentBookId == 0{
            storage.setCurrentBooKId(bookId: 200)
            return 200
        }else{
            storage.setCurrentBooKId(bookId: currentBookId)
        }
        return currentBookId
    }
    
}


