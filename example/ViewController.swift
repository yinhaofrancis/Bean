//
//  ViewController.swift
//  example
//
//  Created by hao yin on 2021/6/11.
//

import UIKit
import Bean

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}
class ViewController2: UIViewController {

    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var btn: UIButton!
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        self.state?.$name.addObserver(observer: StateObserver(callback: { v in
            print(v)
        }))
        self.state?.$name.addObserver(observer: StateObserver(callback: { b in
            print(b)
        }))
    }

    @IBAction func change(_ sender: Any) {
     
        self.state?.name = "\(arc4random())"
        var t = "htp:\\{duir}\\asdsad\\{dashdj}"
        print(t)
        let a = UrlTemplete(stringLiteral: t).reg.matches(in: t, options: .reportCompletion, range: NSRange(location: 0, length: t.count))
        print(a)
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
}
