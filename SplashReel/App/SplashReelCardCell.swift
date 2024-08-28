//
//  SplashReelCardCell.swift
//  SplashReel
//
//  Created by Shirish Koirala on 26/8/2024.
//

import UIKit

class SplashReelCardCell: UICollectionViewCell {
    static let identifier: String = "SplashReelCardCell"
    
    var isCenter: Bool = false {
        didSet {
            transformIfNeeded()
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup () {
        contentView.addSubview(imageView)
        contentView.layer.cornerRadius = 50
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    func configure (with imageName: String) {
        imageView.image = UIImage(named: imageName)
    }
    
    func transformIfNeeded() {
        UIView.animate(withDuration: 0.2) {
            if self.isCenter {
                self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.imageView.alpha = 1.0
                self.imageView.layer.shadowOpacity = 1
                self.imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
                self.imageView.layer.shadowRadius = 3
            } else {
                self.imageView.transform = CGAffineTransform.identity
                self.imageView.alpha = 0.5
                self.imageView.layer.shadowOpacity = 0
            }
        }
    }
}
