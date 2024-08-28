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
    
    var data: [SplashReelModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var collectionViewFlowLayout: CollectionViewLayout = {
        let layout = CollectionViewLayout()
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
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
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 0, bottom: 10.0, right: 0)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: screenHeight * 0.659),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -screenHeight * 0.13)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.showsHorizontalScrollIndicator = false
        getData()
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.currentIndex += 1
            let nextInexPath = IndexPath(row: self.currentIndex, section: 0)
            self.collectionView.scrollToItem(at: nextInexPath, at: .centeredHorizontally, animated: true)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SplashReelCardCell.identifier, for: indexPath) as! SplashReelCardCell
        let recycledIndex = indexPath.row % data.count
        cell.configure(with: data[recycledIndex].cardImage)
        cell.isCenter = (indexPath.row == currentIndex)
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        let centerPoint = CGPoint(x: (scrollView.bounds.width / 2) + scrollView.contentOffset.x, y: scrollView.bounds.height / 2 + scrollView.contentOffset.y)
        
        if let centerIndexPath = collectionView.indexPathForItem(at: centerPoint) {
            if centerIndexPath.row != currentIndex {
                currentIndex = centerIndexPath.row
                collectionView.visibleCells.forEach { cell in
                    if let cell = cell as? SplashReelCardCell,
                       let indexPath = collectionView.indexPath(for: cell) {
                        cell.isCenter = (indexPath.row == centerIndexPath.row)
                    }
                }
            }
        }
        
        let itemSize = self.collectionView.contentSize.width / CGFloat(totalElements)
        
        if scrollView.contentOffset.x > itemSize * CGFloat(data.count){
            collectionView.contentOffset.x -= itemSize * CGFloat(data.count)
        }
        
        if scrollView.contentOffset.x < 0{
            collectionView.contentOffset.x += itemSize * CGFloat(data.count)
        }
    }
}

extension SplashReelVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = screenHeight * 0.1814
        let cellWidth = screenWidth * 0.32
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

final class CollectionViewLayout: UICollectionViewFlowLayout {
    var previousOffset: CGFloat = 0.0
    
    override func prepare() {
        super.prepare()
        self.scrollDirection = .horizontal
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        let attrArray = super.layoutAttributesForElements(in: targetRect)
        
        let horizontalCenter = proposedContentOffset.x + (collectionView.bounds.width / 2)
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        
        for layoutAttributes in attrArray ?? [] {
            let itemHorizontalCenter = layoutAttributes.center.x
            if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        let nextOffset = proposedContentOffset.x + offsetAdjustment
        return CGPoint(x: nextOffset, y: proposedContentOffset.y)
    }
}
