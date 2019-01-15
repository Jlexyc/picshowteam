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
    
    private var page: UInt = 0
    private let perPage: UInt = 50
    private var searchText: String?
    
    public func search(_ searchText: String, completionHandler: @escaping (Array<ImageModel>?, Error?, Bool) -> Void) -> URLSessionDataTask? {
        self.searchText = searchText
        return self.search(searchText, page: 0, completionHandler: completionHandler)
    }
    
    private func search(_ searchText: String, page: UInt, completionHandler: @escaping (Array<ImageModel>?, Error?, Bool) -> Void) -> URLSessionDataTask? {
        return flickerProvider.search(searchText) { (response, error) in
            guard let safeResponse = response else {
                print("Response with error")
                if let safeError = error {
                    print(":", safeError)
                }
                DispatchQueue.main.async {
                    completionHandler(nil, error, false)
                }
                return
            }
            
            var responseArray = [ImageModel]()
            
            guard let mainObject = safeResponse["photos"] as? Dictionary<String, Any> else {
                DispatchQueue.main.async {
                    completionHandler(nil, nil, false)
                }
                return
            }
            
            guard let photos = mainObject["photo"] as? Array<Dictionary<String, Any>> else {
                DispatchQueue.main.async {
                    completionHandler(nil, nil, false)
                }
                return
            }
            
            var moreResults = false
            if let currentPage = mainObject["page"] as? UInt, let totalPages = mainObject["pages"] as? UInt {
                moreResults = currentPage <= totalPages
            }
            
            for imageData in photos {
                responseArray.append(ImageModel(imageData))
            }
            DispatchQueue.main.async {
                completionHandler(responseArray, nil, moreResults)
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
    
    public func clearSearch() {
        self.page = 0
        self.searchText = nil
    }
    
    public func loadNextPage(completionHandler: @escaping (Array<ImageModel>?, Error?, Bool) -> Void) -> URLSessionDataTask? {
        guard let safeText = self.searchText else {
            print("There no ongoing search")
            return nil
        }
        
        self.page += 1
        return self.search(safeText, page: self.page, completionHandler: completionHandler)
    }
}
