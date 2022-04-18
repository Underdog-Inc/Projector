//
//  MovieDetailVC.swift
//  Projector
//
//  Created by Fatih Gursoy on 4.02.2022.
//

import UIKit

class MovieDetailVC: UIViewController {
    
    @IBOutlet private weak var movieImage: UIImageView!
    @IBOutlet private weak var movieNameLabel: UILabel!
    @IBOutlet private weak var overviewText: UILabel!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var voteCountLabel: UILabel!
    @IBOutlet private weak var runTimeLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var bookmarkButton: UIButton!
    @IBOutlet private weak var watchButton: UIButton!
    
    @IBOutlet private weak var genreCollectionView: UICollectionView!
    @IBOutlet private weak var castCollectionView: UICollectionView!
    
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    
    private var CoreDataService = CoreService()
    private var watchList = [WatchList]()

    var movieViewModel: MovieViewModel?
    var creditsViewModel = CreditsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMovieDetail()
        configureCollectionView()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        movieImage.layer.maskedCorners = [.layerMinXMaxYCorner]
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                
        moreButton.titleLabel?.numberOfLines = 0
        moreButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
    func configureCollectionView() {
        
        genreCollectionView.delegate = self
        genreCollectionView.dataSource = self

        castCollectionView.delegate = self
        castCollectionView.dataSource = self

        genreCollectionView.register(UINib(nibName: "GenreCellView", bundle: nil), forCellWithReuseIdentifier: "GenreCell")

        castCollectionView.register(UINib(nibName: "CastCellView", bundle: nil), forCellWithReuseIdentifier: "CastCell")
    }
    
    
    func fetchMovieDetail() {
        
        if let movieViewModel = movieViewModel {
          
            guard let id = movieViewModel.id else { return }
            
            movieViewModel.delegate = self
            creditsViewModel.delegate = self

            movieViewModel.fetchMovieDetail(with: id)
            creditsViewModel.fetchCredits(with: id)
            
            movieViewModel.updateWatchStatus()
            
        }
    }
    
    @IBAction func watchButtonClicked(_ sender: Any) {
        
        watchButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        addToWatchList()
        setButtonImage()
        
        notificationCenter.post(name: NSNotification.Name(rawValue: "UpdateWatchList"), object: nil)
        
    }
    
    @IBAction func bookmarkButtonClicked(_ sender: Any) {
        
        if let movieId = movieViewModel?.id {
        
            if let movie = CoreDataService.fetchMovie(movieId)  {
                CoreDataService.deleteItem(with: movie)
                bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            } else {
                addToWatchList()
            }
        }
        notificationCenter.post(name: NSNotification.Name(rawValue: "UpdateWatchList"), object: nil)
    }
    
    func addToWatchList() {

//        bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
//
//        let context = CoreDataModel.context
//        watchList = CoreDataService.watchList
//
//        if watchList.count < 1 {
//
//            let newMovie = NSEntityDescription.insertNewObject(forEntityName: CoreDataModel.entitiyName, into: context)
//
//            newMovie.setValue(movieViewModel?.id, forKey:"movieId")
//            newMovie.setValue(false, forKey: "isWatched")
//            makeAlert(titleString: "Added to Watch List", messageString: "")
//
//        } else {
//
//            if !(watchList.contains(where: { $0.movieId == movieViewModel?.id})) {
//                let newMovie = NSEntityDescription.insertNewObject(forEntityName: CoreDataModel.entitiyName, into: context)
//
//                newMovie.setValue(movieViewModel?.id, forKey:"movieId")
//                newMovie.setValue(false, forKey: "isWatched")
//                makeAlert(titleString: "Added to Watch List", messageString: "")
//            }
//        }
//        CoreDataService.saveToCoreData()
    }
    
    func setButtonImage() {
              
//        watchList = CoreDataService.watchList
//        let movie = watchList.filter { $0.movieId == movieViewModel?.id }
//        guard let movie = movie.first else {return}
//
//        movie.isWatched = !(movie.isWatched)
//        movieViewModel?.updateWatchStatus()
//
//        DispatchQueue.main.async {
//            if movie.isWatched {
//                self.watchButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
//            } else {
//                self.watchButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
//            }
//        }
    }
    
    @IBAction func moreLikeButtonClicked(_ sender: Any) {
        
//        let moreLikeVC = MoreMoviesVC()
//        self.navigationController?.pushViewController(moreLikeVC, animated: true)
//        moreLikeVC.movieId = movieViewModel?.id
    }


}

extension MovieDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
            
        case genreCollectionView:
            return movieViewModel?.genres?.count ?? 0
    
        case castCollectionView:
            return creditsViewModel.cast?.count ?? 0
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            
        case genreCollectionView:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell", for: indexPath) as? GenreCell else { fatalError("Could not Load") }
            
            let genreViewModel = movieViewModel?.genreAtIndex(indexPath.row)
            cell.configure(viewModel: genreViewModel)

            return cell
         
        case castCollectionView:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as? CastCell else { fatalError("Could not Load") }

            let creditViewModel = CreditViewModel(cast: creditsViewModel.castAtIndex(indexPath.row).cast)
            
            cell.configure(viewModel: creditViewModel)
            
            return cell
            
        default:
            
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView {
            
        case genreCollectionView:
        guard let item = movieViewModel?.genres?[indexPath.row].name else {return CGSize()}
            
            let itemWidth = (item.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]).width) + 40
            let itemHeight = collectionView.bounds.height * 1

            return CGSize(width: itemWidth, height: itemHeight)
            
        case castCollectionView:
            
            let itemWidth = collectionView.bounds.width * 0.25
            let itemHeight = collectionView.bounds.height

            return CGSize(width: itemWidth, height: itemHeight)
            
        default:
            
            return CGSize()
        }
        
    }
    
    
}

extension MovieDetailVC: MovieViewModelDelegate {
    
    func updateUI() {
        
        guard let movieViewModel = movieViewModel else { return }
        
        self.overviewText.text = movieViewModel.overview
        self.movieNameLabel.text = movieViewModel.movieTitle
        self.ratingLabel.text = "\(movieViewModel.rating)"
        self.yearLabel.text = movieViewModel.year
        self.voteCountLabel.text = "\(movieViewModel.voteCount) votes"
        self.runTimeLabel.text = "\(movieViewModel.runTime) min"

        if let photoURL = movieViewModel.backdropURL {
            self.movieImage.setImage(url: photoURL)
        }
                
        if let isWatched = movieViewModel.isWatched {
                
            self.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            
            if isWatched {
                self.watchButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            } else if !isWatched {
                self.watchButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            }
        }

        self.genreCollectionView.reloadData()
    }
    
}

extension MovieDetailVC: CreditsViewModelDelegate {
    
    func updateCastCollectionView() {
        castCollectionView.reloadData()
    }
    
    
    
    
}
