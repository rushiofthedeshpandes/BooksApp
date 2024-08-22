//
//  BookViewController.swift
//  BooksApp
//
//  Created by Rushikesh Deshpande on 19/08/24.
//


import UIKit
import Combine

class BookViewController: UIViewController  {
    
    //MARK: -  PROPERTIES

    var viewModel : BooksViewModel!
    private let apiManager = APIManager()
    private let storage = LocalStorage()
    private var subscriber: AnyCancellable?
    private var books : [BookItem] = []
    private var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    private var favoriteBooks : [Int] = []
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    //MARK: -  VIEW LIFE CYCLE & ASSOCIATED METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupConstraints()
        setupViewModel()
        observeViewModel()
        setupNavigationBar()
        addRefreshControl()
        setupActivityIndicator()
        setupTheme()
        fetchBooks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.fetchBooks()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout() 
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !viewModel.isLoading) /*&& self.books.count < totalCount)*/{
            fetchBooks()
        }
    }
   
    @objc private func addBook() {
        let addBookVC = AddBookViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(addBookVC, animated: true)
    }
    
}

//MARK: - SETTING UP UI CONTROLS & CONSTRAINTS, NAVIGATION CONTROLS
extension BookViewController{
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        // Center the activity indicator in the view
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = K.Books
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addBook))
    }
    
    private func setupTheme() {
        overrideUserInterfaceStyle = .unspecified
    }
}

//MARK: - REFRESH CONTROL FUNCTIONS & DECLARATION

extension BookViewController{
    
    private func addRefreshControl() {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributedTitle = NSAttributedString(string: K.RefreshBooks, attributes: attributes)
        refreshControl.attributedTitle = attributedTitle
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc func refresh(_ sender: AnyObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.fetchBooks()
        }
    }
}

//MARK: - COLLECTION VIEW DELEGATE & DATA SOURCE METHODS


extension BookViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func setupCollectionView() {
        
        view.backgroundColor = .systemBackground

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width / 2 - 5, height: 275)
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: K.BookCell)
        collectionView.refreshControl = refreshControl
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.BookCell,
                                                      for: indexPath) as! BookCell
        let book = books[indexPath.row]
        cell.configure(with: book)
        if  viewModel.getFavorites().contains(book.id){
            cell.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            cell.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBook = books[indexPath.row]
        let detailVC = BookDetailViewController(bookId: selectedBook.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


//MARK: - VIEW MODEL BINDING, OBSERVED METHODS & UPDATES IN VIEW

extension BookViewController{
    
    private func setupViewModel() {
        viewModel = BooksViewModel(apiManager: apiManager,
                                   endpoint: .books,
                                   storage: storage)
    }
       
    private func fetchBooks() {
        guard !viewModel.isLoading else { return }
        activityIndicator.startAnimating()
        if self.refreshControl.isRefreshing{
            self.refreshControl.endRefreshing()
        }
        viewModel.fetchBooks()
    }
       
    private func observeViewModel() {
        favoriteBooks = viewModel.getFavorites()
        subscriber = viewModel.bookSubject.sink(receiveCompletion: { (resultCompletion) in
            switch resultCompletion {
            case .failure(_):
                 DispatchQueue.main.async {
                     self.activityIndicator.stopAnimating()
                 }
            default: break
            }
        }) { (books) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.books = books
                self.collectionView.reloadData()
            }
        }
    }
}

extension BookViewController : BookCellUpdater{
    func updateCell(with bookId: Int) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func deleteBook(with bookId: Int) {
        if bookId < 200{
            self.showAlert(title: K.Books, message: K.youCantDeleteAPIBook, action1: K.okay) {}
        }else{
            self.showAlert(title: K.Books, message: K.areYouSureToDeleteBook, action1: K.no, action2: K.yes, handler1: {
                print("No Selected")
            },handler2: {
                self.viewModel.deleteCustomBook(for: bookId)
                self.viewModel.fetchBooks()
            })
        }
        
    }
    
}
