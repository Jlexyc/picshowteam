//
//  FlickerProvider.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import Foundation

class FlickerProvider {
    private let key = "7f41feb152f4e25aee59513727d8dccc"
    private let secret = "973df75bb7fc67b7"
    private let endpoint = "https://api.flickr.com/services/rest/"
    
    public func search(_ searchText: String, completionHandler: @escaping (Dictionary<String, Any>?, Error?) -> Void) -> URLSessionDataTask? {
        let methodName = "flickr.photos.search"
        let url = URL(string: "\(self.endpoint)?method=\(methodName)&api_key=\(self.key)&text=\(searchText)&format=json&nojsoncallback=1")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST";
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let safeData = data else { return }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: safeData, options: .allowFragments) as? Dictionary<String, Any>
                completionHandler(jsonObject, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    public func loadImage(_ url: String, completionHandler: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: url) else {
            completionHandler(nil, nil)
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            completionHandler(data, error)
        }
        task.resume()
        return task
    }
}
