//
//  LoadingCell.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/15/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import UIKit

class LoadingCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        self.activityIndicator.startAnimating()
    }
}
