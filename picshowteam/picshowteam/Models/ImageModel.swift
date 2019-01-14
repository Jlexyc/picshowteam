//
//  ImageModel.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import Foundation

class ImageModel {
    private let json: Dictionary<String, Any>
    public var title: String {
        return self.json["title"] as? String ?? "N/A"
    }
    var farm: String {
        return (self.json["farm"] as? NSNumber)?.stringValue ?? ""
    }
    var id: String {
        return self.json["id"] as? String ?? ""
    }
    var secret: String {
        return self.json["secret"] as? String ?? ""
    }
    var server: String {
        return self.json["server"] as? String ?? ""
    }
    
    var thumbImageUrl: String {
        return "https://farm\(self.farm).staticflickr.com/\(self.server)/\(self.id)_\(self.secret)_t.jpg"
    }
    
    var bigImageUrl: String {
        return "https://farm\(self.farm).staticflickr.com/\(self.server)/\(self.id)_\(self.secret)_h.jpg"
    }
    
    init(_ model: Dictionary<String, Any>) {
        self.json = model;
    }
}
