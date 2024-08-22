//
//  UIImageView+Extension.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 20/08/24.
//

import UIKit
import Foundation


extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        // Set placeholder image
        self.image = placeholder
        
        // Check if image is already cached
        if let cachedImage = ImageCache.shared.image(for: url) {
            self.image = cachedImage
            return
        }
        
        // Fetch image from URL
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            let image = UIImage(data: data)
            // Cache the image
            ImageCache.shared.save(image: image, for: url)
            DispatchQueue.main.async {
                self.image = image
            }
        }
        task.resume()
    }
}


class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSURL, UIImage>()
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func save(image: UIImage?, for url: URL) {
        guard let image = image else { return }
        cache.setObject(image, forKey: url as NSURL)
    }
}

