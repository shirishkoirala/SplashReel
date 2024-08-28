//
//  BottomCollectionViewFlowLayout.swift
//  SplashReel
//
//  Created by Shirish Koirala on 28/8/2024.
//
import UIKit

final class BottomCollectionViewFlowLayout: UICollectionViewFlowLayout {
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
