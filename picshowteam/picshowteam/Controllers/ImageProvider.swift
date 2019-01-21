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
    /**
     Shared instance of ImageProvider
    */
    public static let shared = ImageProvider()
    
    private let flickerProvider = FlickerProvider()
    private var imageCache = [String: UIImage]()
    
    private var page: UInt = 0
    private let perPage: UInt = 50
    private var searchText: String?
    
    /**
     Use this method to perform new image search.
     - Parameter searchText: text that used to search images.
     - Parameter completionHandler: callback called when results obtained. Called on MAIN thread.
     - Parameter array: array of images. *nil* means is something wrong. Check *error* in this case.
     - Parameter error: error that occured during request and parsing. *nil* means request is successful.
     - Parameter moreResults: bool flag that shows wether next page available or not.
     - Returns: URLSessionDataTask so you can cancel task if needed or ignore. Could be *nil*.
     */
    public func search(_ searchText: String, completionHandler: @escaping (_ array: Array<ImageModel>?, _ error: ErrorModel?, _ moreResults: Bool) -> Void) -> URLSessionDataTask? {
        self.searchText = searchText
        return self.search(searchText, page: 0, completionHandler: completionHandler)
    }
    
    private func search(_ searchText: String, page: UInt, completionHandler: @escaping (Array<ImageModel>?, ErrorModel?, Bool) -> Void) -> URLSessionDataTask? {
        return flickerProvider.search(searchText) { (response, error) in
            guard let safeResponse = response else {
                let appError = ErrorModel(error: error, type: .networking)
                DispatchQueue.main.async {
                    completionHandler(nil, appError, false)
                }
                return
            }
            
            var responseArray = [ImageModel]()
            
            guard let mainObject = safeResponse["photos"] as? Dictionary<String, Any> else {
                let appError = ErrorModel(message: "No {photos} dictionary in response", type: .parsing)
                DispatchQueue.main.async {
                    completionHandler(nil, appError, false)
                }
                return
            }
            
            guard let photos = mainObject["photo"] as? Array<Dictionary<String, Any>> else {
                let appError = ErrorModel(message: "No {photo} array in response", type: .parsing)
                DispatchQueue.main.async {
                    completionHandler(nil, appError, false)
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
    
    /**
     Method downloads image in background
     - Parameter url: string url of image.
     - Parameter completionHandler: callback called when results obtained. Called on MAIN thread.
     - Parameter image: UIImage object. *nil* means is something wrong. Check *error* in this case.
     - Parameter error: error that occured during request and parsing. *nil* means request is successful.
     - Returns: URLSessionDataTask so you can cancel task if needed or ignore. Could be *nil*.
     */
    public func getImage(_ url: String, completionHandler: @escaping (_ image: UIImage?,_ error: ErrorModel?) -> Void) -> URLSessionDataTask? {
        if let image = self.imageCache[url] {
            DispatchQueue.main.async {
                completionHandler(image, nil)
            }
            return nil
        }
        
        return self.flickerProvider.loadImage(url) { (data, error) in
            guard let safeData = data, let image = UIImage(data: safeData) else {
                let appError = ErrorModel(message: "Unable to create image from data", type: .parsing)
                DispatchQueue.main.async {
                    completionHandler(nil, appError)
                }
                return
            }
            
            self.imageCache[url] = image
            DispatchQueue.main.async {
                completionHandler(image, nil)
            }
        }
    }
    
    /**
     Use this method to clear current search.
     */
    public func clearSearch() {
        self.page = 0
        self.searchText = nil
    }
    
    /**
     Use this method to get next page of current search.
     - Parameter completionHandler: callback called when results obtained. Called on MAIN thread.
     - Parameter array: array of images. *nil* means is something wrong. Check *error* in this case.
     - Parameter error: error that occured during request and parsing. *nil* means request is successful.
     - Parameter moreResults: bool flag that shows wether next page available or not.
     - Returns: URLSessionDataTask so you can cancel task if needed or ignore. Could be *nil* if there no ongoing search.
     */
    public func loadNextPage(completionHandler: @escaping (_ array: Array<ImageModel>?, _ error: ErrorModel?, _ moreResults: Bool) -> Void) -> URLSessionDataTask? {
        guard let safeText = self.searchText else {
            // There no pages for no searchtext
            return nil
        }
        
        if safeText.isEmpty {
            // Need to use "Recent" request to get images without the string
            return nil
        }
        self.page += 1
        return self.search(safeText, page: self.page, completionHandler: completionHandler)
    }
}
