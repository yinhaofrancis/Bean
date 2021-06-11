//
//  BeanTests.swift
//  BeanTests
//
//  Created by hao yin on 2021/6/10.
//

import XCTest

@testable import Bean

class BeanTests: XCTestCase {

    var timer:Timer?
    var bvc:BeanVC!
    var bvcw:Bean2VC!
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testExample() throws {
        bvc = BeanVC()
        bvcw = Bean2VC()
        if #available(macOS 10.12, *) {
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self]t in
                self?.bvc.go()
            })
        }
        RunLoop.main.run()
    }
}


public struct Model{
    var name:String
    var uid:String
    var count:Int
}

public class BeanVC:NSObject{
    
    @Bean(name: "Model")
    var model:Model?
    
    
    func go(){
        let c = self.model?.count ?? 0
        $model.setState(state: Model(name: "dsd", uid: "dsdsd", count: c + 1))
    }
}


public class Bean2VC:NSObject{
    
    @Bean(name: "Model")
    var model:Model?
    public override init() {
        super.init()
        $model.observer = BeanObserver()
        $model.observer?.setChange(call: { a, b in
            print(b as Any)
        })
    }
}
