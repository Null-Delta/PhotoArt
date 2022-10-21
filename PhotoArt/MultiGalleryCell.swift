//
//  MultiGalleryCell.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 20.10.2022.
//

import UIKit

class MultiGalleryCell: UICollectionViewCell {
    private var images: [UIImageView] = []
    private var imagesCount = 0

    func clearImages() {
        for view in images {
            view.image = nil
        }
    }

    func updateImage(at: Int, image: UIImage?) {
        images[at].image = image
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        imagesCount = Int(frame.width / frame.height)

        for imageIndex in 0..<imagesCount {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(imageIndex) * frame.height, y: 0, width: frame.height, height: frame.height))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            contentView.addSubview(imageView)
            images.append(imageView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
