//
//  picshowteamTests.swift
//  picshowteamTests
//
//  Created by Oleksii Kozulin on 1/14/19.
//  Copyright © 2019 Oleksii Kozulin. All rights reserved.
//

import XCTest
@testable import picshowteam

class picshowteamTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Example test. Just need more time to cover all logic like pagination as need to build injection with mocks to replace real network requests.
    func testImageURL() {
        let object = ["server": "4822", "id": "44355672190", "farm": 5, "secret": "178c602e76",  "title": "Some title"] as [String : Any]

        let thumbImgUrl = "https://farm5.staticflickr.com/4822/44355672190_178c602e76_t.jpg"
        let bigImgUrl = "https://farm5.staticflickr.com/4822/44355672190_178c602e76_h.jpg"
            
        let model = ImageModel(object)
        
        print("thumbImageUrl", model.thumbImageUrl)
        XCTAssertTrue(model.thumbImageUrl == thumbImgUrl, "Bad Thumb Image URL Creation")
        XCTAssertTrue(model.bigImageUrl == bigImgUrl, "Bad Big Image URL Creation")
    }

}
