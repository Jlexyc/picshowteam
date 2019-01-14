//
//  ImageCollectionViewController.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UICollectionViewController {

    var images = [ImageModel]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = ImageProvider.shared.search("girls") { (imageArray, error) in
            guard let safeImageArray = imageArray else {
                print("Response with error")
                if let safeError = error {
                    print(":", safeError)
                }
                return
            }
            self.images = safeImageArray
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}

