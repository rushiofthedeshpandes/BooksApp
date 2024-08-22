//
//  Helper.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 20/08/24.
//

import Foundation

class Helper{
    
    static let shared = Helper()
    
    func parseISO8601Date(dateString: String) -> Date? {
        let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
           formatter.timeZone = TimeZone(abbreviation: "UTC") // Set time zone to UTC
           return formatter.date(from: dateString)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Medium style gives a format like "Aug 19, 2024"
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func formattedPublicationDate(from isoDateString: String) -> String? {
        guard let date = parseISO8601Date(dateString: isoDateString) else {
            return nil
        }
        return formatDate(date: date)
    }
    
    
    func convertToItems(_ books: [Book]) -> [BookItem]{
        var items : [BookItem] = []
        for book in books{
            let newItem = convertToBookItem(book)
            items.append(newItem)
        }
        return items
    }
    
    func convertToBookItem(_ book: Book) -> BookItem{
        let newItem = BookItem()
        newItem.id = book.id
        newItem.title = book.title
        newItem.author = book.author
        newItem.description = book.description
        newItem.cover = book.cover
        newItem.publicationDate = book.publicationDate
        newItem.isFavorite = false
        return newItem
    }
//    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//    let date = dateFormatter.date(from: "2017-01-09T11:00:00.000Z")
//    print("date: \(date)")
}
