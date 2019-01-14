//
//  ImageProvider.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import Foundation

class ImageProvider {
    public static let shared = ImageProvider()
    private let flickerProvider = FlickerProvider()
    
    public func search(_ searchText: String, completionHandler: @escaping (Array<ImageModel>?, Error?) -> Void) -> URLSessionDataTask {
        return flickerProvider.search(searchText) { (response, error) in
            guard let safeResponse = response else {
                print("Response with error")
                if let safeError = error {
                    print(":", safeError)
                }
                completionHandler(nil, error)
                return
            }
            
            var responseArray = [ImageModel]()
            
            guard let mainObject = safeResponse["photos"] as? Dictionary<String, Any> else {
                completionHandler(nil, nil)
                return
            }
            guard let photos = mainObject["photo"] as? Array<Dictionary<String, Any>> else {
                completionHandler(nil, nil)
                return
            }
            
            for imageData in photos {
                responseArray.append(ImageModel(imageData))
            }
            completionHandler(responseArray, nil)
        }
    }
}
