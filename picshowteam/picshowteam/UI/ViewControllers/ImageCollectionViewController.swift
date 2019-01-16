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

class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, GalleryItemsDataSource, GalleryDisplacedViewsDataSource, UISearchBarDelegate {
    
    lazy var searchBar: UISearchBar = UISearchBar()
    var searchTimer: Timer?
    var loading: Bool = false
    var moreResults: Bool = false {
        didSet {
            self.collectionView.reloadData()
        }
    }
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
        self.searchBar.sizeToFit()
        self.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.searchBar.placeholder = "Type text here"
        self.searchBar.delegate = self
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:self.searchBar)
        self.navigationItem.titleView = self.searchBar
    }
    
    func searchImages() {
        guard let searchText = self.searchBar.text else {
            self.images = []
            self.moreResults = false
            ImageProvider.shared.clearSearch()
            return
        }
        
        if (searchText.isEmpty) {
            self.images = []
            self.moreResults = false
            ImageProvider.shared.clearSearch()
            return
        }
        
        self.loading = true
        self.moreResults = true
        _ = ImageProvider.shared.search(searchText) { (imageArray, error, moreResults) in
            self.loading = false
            guard let safeImageArray = imageArray else {
                self.moreResults = false
                print("Response with error")
                if let safeError = error {
                    print(":", safeError)
                }
                return
            }
            self.moreResults = moreResults
            self.images = safeImageArray
        }
    }
    
    func loadNextPage() {
        if !self.loading {
            _ = ImageProvider.shared.loadNextPage { (imageArray, error, moreResults) in
                guard let safeImageArray = imageArray else {
                    self.moreResults = false
                    print("Error loading next page")
                    if let safeError = error {
                        print(":", safeError)
                    }
                    return
                }
                self.moreResults = moreResults
                self.images += safeImageArray
            }
        }
    }

    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.navigationController?.navigationBar.sizeToFit()
    }
    
    // MARK: - CollectionViewDelegate & DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count + (self.moreResults ? 1 : 0)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row >= self.images.count) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            return cell
        }
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
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.images.count {
            self.loadNextPage()
        }
    }
    
    // MARK: - GalleryItemsDataSource & GalleryDisplacedViewsDataSource
    func itemCount() -> Int {
        return self.galleryItems.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return self.galleryItems[index]
    }
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return (collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCell)?.imageView
    }
    
    // MARK: - FlowDelegate
    private let insets = UIEdgeInsets(top: 20.0, // TODO: Extract this value to general Theme/Style manager
                                             left: 20.0,
                                             bottom: 20.0,
                                             right: 20.0)
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns = (self.view.frame.width / 120)

        let offset = insets.left * (columns + 1)
        let fullWidth = self.view.frame.width - offset
        let itemWidth = fullWidth / columns
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.left
    }
    
    //MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchImages()
        }
        
        self.searchTimer?.invalidate()
        self.searchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
            self.searchImages()
        })
    }
}
