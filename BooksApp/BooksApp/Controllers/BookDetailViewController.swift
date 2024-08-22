//
//  BookDetailViewController.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 20/08/24.
//
import UIKit
import Combine

class BookDetailViewController: UIViewController {
    
    var viewModel : BooksViewModel!
    private let apiManager = APIManager()
    private let storage = LocalStorage()
    private var subscriber: AnyCancellable?
    
    private var bookId: Int
    private var bookItem : BookItem?
    private var book : Book?
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let coverImageView = UIImageView()
    private let publicationDateLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)

    init(bookId: Int) {
        self.bookId = bookId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupViewModel()
        observeViewModel()
        fetchBookDetails()
    }
    
    private func setupViews() {
        addSubViews()
        addConstraints()
        customiseSubviews()
    }
    
    fileprivate func addSubViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(authorLabel)
        view.addSubview(coverImageView)
        view.addSubview(publicationDateLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(favoriteButton)
    }
    
    fileprivate func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        publicationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            coverImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 10),
            coverImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: 10),
            coverImageView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            authorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            authorLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            
            publicationDateLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 10),
            publicationDateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            publicationDateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            
            
            descriptionLabel.topAnchor.constraint(equalTo: publicationDateLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            favoriteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25)
            
        ])
    }
    
    fileprivate func customiseSubviews() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        titleLabel.numberOfLines = 2
        
        authorLabel.font = .systemFont(ofSize: 15, weight: .bold)
        authorLabel.textColor = .systemBrown
        
        publicationDateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        publicationDateLabel.textColor = .systemGreen
        
        descriptionLabel.font = .systemFont(ofSize: 11, weight: .regular)
        descriptionLabel.textColor = .systemGray
        
        
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    }
    
    
    
    private func configureViews(for bookItem: BookItem) {
        title = bookItem.title
        titleLabel.text = bookItem.title
        authorLabel.text = "By \(bookItem.author)"
        descriptionLabel.text = bookItem.description
        descriptionLabel.numberOfLines = 0
        publicationDateLabel.text = "Published on : \(Helper.shared.formattedPublicationDate(from: bookItem.publicationDate) ?? "")"
        
        // Load image asynchronously
        if let url = URL(string: bookItem.cover) {
            coverImageView.loadImage(from: url, placeholder: UIImage(named: "placeholder"))
            coverImageView.contentMode = .scaleAspectFit
        }
        if viewModel.getFavorites().contains(bookItem.id){
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
    }
    
    @objc private func toggleFavorite() {
        // Handle toggle favorite action
        viewModel.toggleFavorite(bookId)
        DispatchQueue.main.async {
            if self.viewModel.getFavorites().contains(self.bookId){
                self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }else{
                self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
    }
}


//MARK: - VIEW MODEL BINDING, OBSERVED METHODS & UPDATES IN VIEW

extension BookDetailViewController{
    private func setupViewModel() {
        viewModel = BooksViewModel(apiManager: apiManager,
                                   endpoint: .books,
                                   storage: storage)
    }
       
    private func fetchBookDetails() {
        guard !viewModel.isLoading else { return }
        viewModel.fetchBookDetails(for: String(bookId))
    }
       
    private func observeViewModel() {
        subscriber = viewModel.bookDetailSubject.sink(receiveCompletion: { (resultCompletion) in
            switch resultCompletion {
            case .failure(_):
                 DispatchQueue.main.async {
                 }
            default: break
            }
        }) { (book) in
            DispatchQueue.main.async {
                let bookItem = Helper.shared.convertToBookItem(book)
                self.configureViews(for: bookItem)
            }
        }
    }
}


