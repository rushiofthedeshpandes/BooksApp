//
//  AddBookViewController.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 20/08/24.
//

import UIKit

class AddBookViewController: UIViewController, UITextFieldDelegate {
    private let viewModel: BooksViewModel
    private let storage = LocalStorage()
    private let titleTextField = UITextField()
    private let authorTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let coverTextField = UITextField()
    private let publicationDateTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    init(viewModel: BooksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
    }
    
    private func setupViews() {
        addSubviews()
        addConstraints()
        addNavigationItem()
        addTextfields()
    }
    
    fileprivate func addConstraints() {
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        authorTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        coverTextField.translatesAutoresizingMaskIntoConstraints = false
        publicationDateTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            authorTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 15),
            authorTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            authorTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            coverTextField.topAnchor.constraint(equalTo: authorTextField.bottomAnchor, constant: 15),
            coverTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            coverTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            publicationDateTextField.topAnchor.constraint(equalTo: coverTextField.bottomAnchor, constant: 15),
            publicationDateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            publicationDateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionTextField.topAnchor.constraint(equalTo: publicationDateTextField.bottomAnchor, constant: 15),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    fileprivate func addSubviews() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleTextField)
        view.addSubview(authorTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(coverTextField)
        view.addSubview(publicationDateTextField)
        view.addSubview(saveButton)
    }
    
    fileprivate func addTextfields(){
        customiseTextField(for: titleTextField, with: "Title")
        customiseTextField(for: authorTextField, with: "Author")
        customiseTextField(for: coverTextField, with: "Cover URL")
        customiseTextField(for: publicationDateTextField, with: "Publication Date")
        customiseTextField(for: titleTextField, with: "Title")
        customiseTextField(for: descriptionTextField, with: "Description")
    }
    
    fileprivate func addNavigationItem(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(saveBook))
    }
    
    fileprivate func customiseTextField(for textfield: UITextField, with placeholder: String) {
        textfield.delegate = self
        textfield.placeholder = placeholder
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.green.cgColor
        textfield.borderStyle = .roundedRect
    }
    
    @objc private func saveBook() {
        guard
            let title = titleTextField.text,
            let author = authorTextField.text,
            let description = descriptionTextField.text,
            let cover = coverTextField.text,
            let publicationDate = publicationDateTextField.text
        else { return }
        
        let book = BookItem()
        book.id = viewModel.getCustomBookId()
        book.title = title
        book.author = author
        book.cover = cover
        book.publicationDate = publicationDate
        book.isFavorite = false
        book.description = description
        viewModel.addCustomBook(book: book)
        self.showAlert(title: K.Success, message: K.customBookAddedSuccess, action1: K.okay) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
