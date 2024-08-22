//
//  UIViewController+Alert.swift
//  QuizInspector
//
//  Created by Rushikesh Deshpande on 20/08/24.

import UIKit

extension UIViewController{
    func showAlert(title: String,
                   message: String,
                   action1: String,
                   action2: String? = nil,
                   handler1: (@escaping()->Void),
                   handler2: (()->Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okay = UIAlertAction(title: action1, style: .default) {  action in
            handler1()
        }
        alert.addAction(okay)
        if let actionTwo = action2{
            let destruct = UIAlertAction(title: action2, style: .destructive) { action in
                handler2?()
            }
            alert.addAction(destruct)
        }
        
      
        present(alert, animated: true)
    }
}
