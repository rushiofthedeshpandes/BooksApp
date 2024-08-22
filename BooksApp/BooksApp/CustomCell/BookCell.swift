//
//  BookCollectionViewCell.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 19/08/24.
//
import UIKit

protocol BookCellUpdater{
    func updateCell(with bookId: Int)
    func deleteBook(with bookId: Int)
}
class BookCell: UICollectionViewCell {
    var delegate : BookCellUpdater?
    private var viewModel : BooksViewModel!
    private let storage = LocalStorage()

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let publicationDate = UILabel()
    let deleteButton = UIButton(type: .system)
    let favoriteButton = UIButton(type: .system)
    private var bookItem: BookItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViewModel() {
        viewModel = BooksViewModel(apiManager: nil,
                                   endpoint: .books,
                                   storage: storage)
    }
    
    private func setupViews() {
        addSubViews()
        addConstraints()
        customiseSubViews()
    }
    
    fileprivate func addSubViews(){
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(publicationDate)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(deleteButton)
    }
    
    fileprivate func addConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        publicationDate.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5),
            imageView.heightAnchor.constraint(equalToConstant: 175),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 3),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 3),
            
            publicationDate.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 5),
            publicationDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            publicationDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 3),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }
    
    fileprivate func customiseSubViews() {
        titleLabel.font = .systemFont(ofSize: 15, weight: .heavy)
        titleLabel.numberOfLines = 2
        
        authorLabel.font = .systemFont(ofSize: 13, weight: .bold)
        authorLabel.textColor = .systemBrown
        
        publicationDate.font = .systemFont(ofSize: 11, weight: .semibold)
        publicationDate.textColor = .systemGreen
        
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        
        deleteButton.addTarget(self, action: #selector(deleteBook), for: .touchUpInside)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
    }
    
    
    func configure(with bookItem: BookItem) {
        self.bookItem = bookItem
        titleLabel.text = bookItem.title
        authorLabel.text = "By \(bookItem.author)"
        if let url = URL(string: bookItem.cover) {
            imageView.loadImage(from: url, placeholder: UIImage(named: "placeholder.jpg"))
            imageView.contentMode = .scaleAspectFit
        }else{
            imageView.image = UIImage(named: "placeholder")
            imageView.contentMode = .scaleAspectFit
        }
        publicationDate.text = "Published on : \(Helper.shared.formattedPublicationDate(from: bookItem.publicationDate) ?? "")"
        contentView.backgroundColor = .systemGroupedBackground
        contentView.layer.cornerRadius = 20
    }
    
    @objc func toggleFavorite(){
        guard let bookId = bookItem?.id else { return  }
        viewModel.toggleFavorite(bookId)
        delegate?.updateCell(with: bookId)
    }
    
    @objc func deleteBook(){
        guard let bookId = bookItem?.id else { return  }
        delegate?.deleteBook(with: bookId)
    }
    
   
}

