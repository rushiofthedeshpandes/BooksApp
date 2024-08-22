//
//  Constants.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 19/08/24.
//

import Foundation

struct K{
    static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
  
    static let HTTP_POST = "POST"
    static let HTTP_GET = "GET"
    static let application_json = "application/json"
    static let content_type = "Content-Type"
    
    static let Main = "Main"
    static let BookViewController = "BookViewController"
    static let BookDetailViewController = "BookDetailViewController"
    static let AddBookViewController = "AddBookViewController"
    static let BookCell = "BookCell"
    static let Books = "Books"
    static let RefreshBooks = "Refreshing Books"
    
    static let baseURL = "https://my-json-server.typicode.com/cutamar/mock/books"
   
    static let unknownError = "Unknown error"
    static let Failure = "Failure"
    static let Error = "Error"
    static let Success = "Success"
    static let okay = "Okay"
    static let yes = "YES"
    static let no = "NO"
    static let invalidInput = "Invalid Input"
    static let areYouSureToDeleteBook = "Are you sure to delete the book"
    static let youCantDeleteAPIBook = "Regret ! Server book cannot be deleted. "
    static let customBookAddedSuccess = "Congratulations ! Your book added successfully !"
    static let localBooksKey = "localBooks"
    static let favorites = "favorites"
    static let currentBookId = "currentBookId"
   
    
    
}

