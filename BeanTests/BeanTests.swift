//
//  BeanTests.swift
//  BeanTests
//
//  Created by WY on 2021/6/10.
//

import XCTest

class BeanTests: XCTestCase {

    var timer:Timer?
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testExample() throws {
        let str = "abcdef"
        let a = str[str.index(str.startIndex, offsetBy: 2)..<str.index(str.startIndex, offsetBy: 3)]

        
        print(a)
    }
}


public struct Model{
    var name:String?
    var uid:String?
    var count:Int?
    var data:String?
}

