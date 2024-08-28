//
//  ViewController.swift
//  SplashReel
//
//  Created by Shirish Koirala on 26/8/2024.
//

import UIKit
struct SplashReelModel{
    var cardImage: String
    var backgroundImage: String
}

class SplashReelVC: UIViewController {
    private let screenHeight = UIScreen.main.bounds.height
    private let screenWidth = UIScreen.main.bounds.width
    private var currentIndex: Int = 0
    private let buffer = 3
    private var totalElements = 0
    private var images: [String] = ["back_to_the_future", "good_fellas", "jaws", "matrix", "pulp_fiction", "shawshank_redemption", "star_wars"]
    
    private var data: [SplashReelModel] = [] {
        didSet {
            bottomCollectionView.reloadData()
        }
    }
    
    private lazy var collectionViewFlowLayout: BottomCollectionViewFlowLayout = {
        let layout = BottomCollectionViewFlowLayout()
        return layout
    }()
    
    private lazy var bottomCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(SplashReelCardCell.self, forCellWithReuseIdentifier: SplashReelCardCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.transform = .identity
        collectionView.isUserInteractionEnabled = true
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 0, bottom: 10.0, right: 0)
        return collectionView
    }()
    
    private lazy var backgroundCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(SplashReelBackgroundCell.self, forCellWithReuseIdentifier: SplashReelBackgroundCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.transform = .identity
        collectionView.isPagingEnabled = true
        collectionView.isUserInteractionEnabled = true
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundCollectionView)
        NSLayoutConstraint.activate([
            backgroundCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(bottomCollectionView)
        NSLayoutConstraint.activate([
            bottomCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: screenHeight * 0.659),
            bottomCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -screenHeight * 0.13)
        ])
        
        getData()
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.currentIndex += 1
            let nextInexPath = IndexPath(row: self.currentIndex, section: 0)
            self.bottomCollectionView.scrollToItem(at: nextInexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func getData() {
        images.forEach { image in
            data.append(SplashReelModel(cardImage: image, backgroundImage: image))
        }
    }
    
}

extension SplashReelVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalElements = buffer + data.count
        return totalElements
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recycledIndex = indexPath.row % data.count
        if collectionView == backgroundCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SplashReelBackgroundCell.identifier, for: indexPath) as! SplashReelBackgroundCell
            var backgroundIndex = recycledIndex + 1
            if(backgroundIndex >= data.count){ backgroundIndex = data.count - 1}
            else if(backgroundIndex < 0){ backgroundIndex =  0}
                
            cell.configure(with: data[backgroundIndex].backgroundImage)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SplashReelCardCell.identifier, for: indexPath) as! SplashReelCardCell
            cell.configure(with: data[recycledIndex].cardImage)
            cell.isCenter = (indexPath.row == currentIndex)
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        if(scrollView == bottomCollectionView){
            let centerPoint = CGPoint(x: (scrollView.bounds.width / 2) + scrollView.contentOffset.x, y: scrollView.bounds.height / 2 + scrollView.contentOffset.y)
            
            if let centerIndexPath = bottomCollectionView.indexPathForItem(at: centerPoint) {
                if centerIndexPath.row != currentIndex {
                    currentIndex = centerIndexPath.row
                    bottomCollectionView.visibleCells.forEach { cell in
                        if let cell = cell as? SplashReelCardCell,
                           let indexPath = bottomCollectionView.indexPath(for: cell) {
                            cell.isCenter = (indexPath.row == centerIndexPath.row)
                        }
                    }
                }
            }
            let itemSize = self.bottomCollectionView.contentSize.width / CGFloat(totalElements)
            
            if scrollView.contentOffset.x > itemSize * CGFloat(data.count){
                bottomCollectionView.contentOffset.x -= itemSize * CGFloat(data.count)
            }
            
            if scrollView.contentOffset.x < 0{
                bottomCollectionView.contentOffset.x += itemSize * CGFloat(data.count)
            }
            
            let itemSizeBackground = self.backgroundCollectionView.contentSize.width / CGFloat(totalElements)
            
            let multiplier = itemSizeBackground / itemSize  
            if(multiplier > 0){
                backgroundCollectionView.contentOffset.x = bottomCollectionView.contentOffset.x * multiplier
            }
        }else if (scrollView == backgroundCollectionView){
            let itemSize = self.bottomCollectionView.contentSize.width / CGFloat(totalElements)
            let itemSizeBackground = self.backgroundCollectionView.contentSize.width / CGFloat(totalElements)
            let multiplier = itemSizeBackground / itemSize
            if(multiplier > 0){
                bottomCollectionView.contentOffset.x = backgroundCollectionView.contentOffset.x / multiplier
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if(scrollView == bottomCollectionView){
            backgroundCollectionView.isScrollEnabled = false
        }else if(scrollView == backgroundCollectionView){
            bottomCollectionView.isScrollEnabled = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        if(scrollView == bottomCollectionView){
            backgroundCollectionView.isScrollEnabled = true
        }else if(scrollView == backgroundCollectionView){
            bottomCollectionView.isScrollEnabled = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView == bottomCollectionView){
            backgroundCollectionView.isScrollEnabled = true
        }else if(scrollView == backgroundCollectionView){
            bottomCollectionView.isScrollEnabled = true
        }
    }
}

extension SplashReelVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == backgroundCollectionView){
            let cellHeight = screenHeight
            let cellWidth = screenWidth
            return CGSize(width: cellWidth, height: cellHeight)
        }else{
            let cellHeight = screenHeight * 0.1814
            let cellWidth = screenWidth * 0.32
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }
}
