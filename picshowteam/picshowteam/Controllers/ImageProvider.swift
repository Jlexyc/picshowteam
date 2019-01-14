//
//  ImageProvider.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import Foundation
import UIKit

class ImageProvider {
    public static let shared = ImageProvider()
    private let flickerProvider = FlickerProvider()
    private var imageCache = [String: UIImage]()
    
    public func search(_ searchText: String, completionHandler: @escaping (Array<ImageModel>?, Error?) -> Void) -> URLSessionDataTask? {
        return flickerProvider.search(searchText) { (response, error) in
            guard let safeResponse = response else {
                print("Response with error")
                if let safeError = error {
                    print(":", safeError)
                }
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            var responseArray = [ImageModel]()
            
            guard let mainObject = safeResponse["photos"] as? Dictionary<String, Any> else {
                DispatchQueue.main.async {
                    completionHandler(nil, nil)
                }
                return
            }
            guard let photos = mainObject["photo"] as? Array<Dictionary<String, Any>> else {
                DispatchQueue.main.async {
                    completionHandler(nil, nil)
                }
                return
            }
            
            for imageData in photos {
                responseArray.append(ImageModel(imageData))
            }
            DispatchQueue.main.async {
                completionHandler(responseArray, nil)
            }
        }
    }
    
    public func getImage(_ url: String, completionHandler: @escaping (UIImage?, Error?) -> Void) -> URLSessionDataTask? {
        if let image = self.imageCache[url] {
            DispatchQueue.main.async {
                completionHandler(image, nil)
            }
            return nil
        }
        
        return self.flickerProvider.loadImage(url) { (data, error) in
            guard let safeData = data, let image = UIImage(data: safeData) else {
                DispatchQueue.main.async {
                    completionHandler(nil, nil)
                }
                return
            }
            
            self.imageCache[url] = image
            DispatchQueue.main.async {
                completionHandler(image, nil)
            }
        }
    }
    
}
