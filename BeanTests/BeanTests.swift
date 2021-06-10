//
//  BeanTests.swift
//  BeanTests
//
//  Created by hao yin on 2021/6/10.
//

import XCTest
@testable import Bean

class BeanTests: XCTestCase {

    @Bean(name: "dddd")
    var namee:String?
    @Coconut
    var keep:Kip = Kip(n: "dddd", m: 44)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        $namee.setState(state: "ddlll")
//        $keep.setState(state: Kip(n: "dddd", m: 5))
        $keep.observer = BeanObserver(callback: { a, b in
            print(a,b)
        })
        print(self.namee)
        print(self.keep)
        self.$keep.setState(state: Kip(n: "dssd", m: 999))
    }
}
struct Kip {
    var n:String
    var m:Int
}
