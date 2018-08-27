//
//  Kit_Tests.swift
//  CrummyTests
//
//  Created by Randy McLain on 8/5/18.
//  Copyright © 2018 CF. All rights reserved.
//

import XCTest
@testable import Crummy 

class Kit_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_emptyKidShouldNotBeNil() {
        let emptyKid = Kid()
        XCTAssertNotNil(emptyKid, "Empty Kid failed to exist.")
        let eKidName = emptyKid.name
        XCTAssertEqual("", eKidName)
        /*
         self.DOBString = ""
         self.insuranceId = ""
         self.nursePhone = ""
         self.kidID = ""
         */
        XCTAssertEqual("", emptyKid.DOBString)
    }
 
}
