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
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    var data: [SplashReelModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var centerCell: SplashReelCardCell?
    lazy var collectionViewFlowLayout: CollectionViewLayout = {
        let layout = CollectionViewLayout()
        layout.minimumLineSpacing = UIScreen.main.bounds.width * 0.1
        layout.minimumInteritemSpacing = UIScreen.main.bounds.width * 0.1
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(SplashReelCardCell.self, forCellWithReuseIdentifier: SplashReelCardCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.transform = .identity
        
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
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
    }
    
    func getData() {
        for(_) in 0..<100 {
            data.append(SplashReelModel(cardImage: "back_to_the_future", backgroundImage: "back_to_the_future"))
        }
    }
    
}

extension SplashReelVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SplashReelCardCell.identifier, for: indexPath) as! SplashReelCardCell
        cell.configure(with: data[indexPath.row].cardImage)
        cell.isCenter = (indexPath.row == collectionViewFlowLayout.currentPage)
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        let centerPoint = CGPoint(x: (scrollView.bounds.width / 2) + scrollView.contentOffset.x, y: scrollView.bounds.height / 2 + scrollView.contentOffset.y)
        
        if let centerIndexPath = collectionView.indexPathForItem(at: centerPoint) {
            if centerIndexPath.row != collectionViewFlowLayout.currentPage {
                collectionViewFlowLayout.currentPage = centerIndexPath.row
                collectionView.visibleCells.forEach { cell in
                    if let cell = cell as? SplashReelCardCell,
                       let indexPath = collectionView.indexPath(for: cell) {
                        cell.isCenter = (indexPath.row == centerIndexPath.row)
                    }
                }
            }
        }
    }
    
}
extension SplashReelVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = screenHeight * 0.1814
        let cellWidth = screenWidth * 0.2617
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
final class CollectionViewLayout: UICollectionViewFlowLayout {
    var previousOffset: CGFloat = 0.0
    var currentPage = 0
    
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
    
    func updateOffset(cv: UICollectionView) -> CGFloat {
        let w = cv.frame.width
        let itemW = itemSize.width
        let sp = minimumLineSpacing
        let edge = (w - itemW - sp * 2) / 2
        let offset = (itemW + sp) * CGFloat(currentPage) - (edge + sp)
        return offset
    }
}
