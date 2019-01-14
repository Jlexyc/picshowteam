//
//  ImageCell.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: AsyncImageView!
    
    override func prepareForReuse() {
        self.imageView.imageUrl = nil
    }
}
