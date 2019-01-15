//
//  AsyncImageView.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import UIKit

class AsyncImageView: UIImageView {
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var task: URLSessionDataTask?
    
    public var imageUrl: String? = nil {
        didSet {
            guard let safeUrl = self.imageUrl else {
                self.image = nil
                task?.cancel()
                return
            }
            self.loadImage(safeUrl)
        }
    }

    private func loadImage(_ url: String) {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        task = ImageProvider.shared.getImage(url) { (image, error) in
            self.activityIndicator.stopAnimating()
            guard let safeImage = image else {
                print("Image not loaded", error ?? "")
                return
            }
            self.image = safeImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.constructor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.constructor()
    }
    
    func constructor() {
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.sizeToFit()
        self.addSubview(self.activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.activityIndicator.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
}
