//
//  ErrorModel.swift
//  picshowteam
//
//  Created by Oleksii Kozulin on 1/21/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import Foundation

enum ErrorType {
    case unknown
    case networking
    case parsing
}

class ErrorModel {
    public var errorMessage: String = ""
    public var originalError: Error?
    public var type: ErrorType
    
    convenience init(error: Error?, type: ErrorType) {
        self.init(error: error, message: nil, type: type)
    }
    
    convenience init(message: String?, type: ErrorType) {
        self.init(error: nil, message: message, type: type)
    }
    
    init(error: Error?, message: String?, type: ErrorType) {
        if let safeMessage = message {
            self.errorMessage = safeMessage
        }
        if let initError = error {
            self.originalError = initError
            self.errorMessage = initError.localizedDescription
        }
        self.type = type
    }
    
    
}
