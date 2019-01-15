//
//  ImageCollectionViewController.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import UIKit
import ImageViewer

extension UIImageView: DisplaceableView {}

class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, GalleryItemsDataSource, GalleryDisplacedViewsDataSource{
    
    var galleryItems = [GalleryItem]()
    var images = [ImageModel]() {
        didSet {
            self.galleryItems = self.images.map({ (model) -> GalleryItem in
                return GalleryItem.image(fetchImageBlock: { (handler) in
                    _ = ImageProvider.shared.getImage(model.bigImageUrl, completionHandler: { (image, error) in
                        guard let safeImage = image else {
                            print("one more error here")
                            return;
                        }
                        handler(safeImage)
                    })
                })
            })
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = ImageProvider.shared.search("car") { (imageArray, error) in
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
    
    // MARK: Collection View Delegate & DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let imageData = self.images[indexPath.row]
        cell.imageView.imageUrl = imageData.thumbImageUrl
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let configuration = [
            GalleryConfigurationItem.deleteButtonMode(.none),
            GalleryConfigurationItem.thumbnailsButtonMode(.none)
        ]
        
        let galleryController = GalleryViewController(startIndex: indexPath.row, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: self, configuration: configuration)
        self.present(galleryController, animated: true)
    }
    
    
    // MARK: GalleryItemsDataSource & GalleryDisplacedViewsDataSource
    
    func itemCount() -> Int {
        return self.galleryItems.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return self.galleryItems[index]
    }
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return (collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCell)?.imageView
    }
    
    // MARK: FlowDelegate
    private let columns: CGFloat = 3
    
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (columns + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / columns
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
