//
//  ViewController.swift
//  example
//
//  Created by WY on 2021/6/11.
//

import UIKit
import Bean

class ViewController: UIViewController {

    @Carrot
    var leaf:Leaf?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leaf?.host = "app-testing.5eplay.com"
    }
    
    
}
class ViewController2: UIViewController {

    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

    @IBAction func change(_ sender: Any) {
        self.state?.$nae.request(param: ["limit":"10","page":"1"])
        
    }

    @Carrot
    var state:AppState?

}

class AppState:Seed {
    static func type() -> SeedType {
        .strong
    }
    
    static func create() -> Seed {
        AppState()
    }
    
    @State
    var name:String = ""
    
    @State(type:StateObserver.self)
    var k:Date = Date()
    
    @Get(url: "/api/csgo/message/system?limit={limit}&page={page}")
    var nae:baseResult?
}

struct baseResult:Codable{
    
    var success:Bool
    var errcode:Int
    var message:String
    var data:String?
}
