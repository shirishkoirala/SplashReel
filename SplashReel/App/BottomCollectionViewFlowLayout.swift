//
//  BottomCollectionViewFlowLayout.swift
//  SplashReel
//
//  Created by Shirish Koirala on 28/8/2024.
//
import UIKit

final class BottomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var previousOffset: CGFloat = 0.0
    private let maxScaleFactor: CGFloat = 1.2
    private let minScaleFactor: CGFloat = 0.8
    
    private let minAlpha: CGFloat = 0.5 // Minimum alpha for non-centered items
    
    override func prepare() {
        super.prepare()
        self.scrollDirection = .horizontal
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        guard let attributesArray = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }) else { return nil }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let centerX = visibleRect.midX
        
        for attributes in attributesArray {
            let distanceFromCenter = abs(attributes.center.x - centerX)
            let scaleDownAmount = min(distanceFromCenter / collectionView.bounds.width, 1.0)
            let scale = maxScaleFactor - minScaleFactor * scaleDownAmount
            
            let alpha = max(minAlpha, 1 - (distanceFromCenter / collectionView.bounds.width))
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            attributes.alpha = alpha
        }
        
        return attributesArray
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }
        
        guard let collectionView = collectionView else { return attributes }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let centerX = visibleRect.midX
        let distanceFromCenter = abs(attributes.center.x - centerX)
        
        let scaleDownAmount = min(distanceFromCenter / collectionView.bounds.width, 1.0)
        let scale = maxScaleFactor - minScaleFactor * scaleDownAmount
        
        let alpha = max(minAlpha, 1 - (distanceFromCenter / collectionView.bounds.width))
        attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        attributes.alpha = alpha
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
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
