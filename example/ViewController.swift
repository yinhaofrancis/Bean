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
        self.state?.$nae.addObserver(observer: { n, old in
            print(n)
        })
    }

    @IBAction func change(_ sender: Any) {
        self.state?.$nae.request(param: ["limit":"10","page":"1"])
        let v = NodeViewController<UIView,AbsoluteLayoutStyle>()
        v.nodeDidLoad { n in
            n.view.backgroundColor = UIColor.white
            let node = Node<UIView, AbsoluteLayoutStyle>(view: UIView())
            node.view.view?.backgroundColor = UIColor.red
            node.size = ElementDual(x: .percent(0.5), y: .percent(0.5))
            node.postion = ElementDual(x: .pt(10), y: .pt(100))
            n.addNode(node: node)
            let node2 = Node<UIView, AbsoluteLayoutStyle>(view: UIView())
            node2.view.view?.backgroundColor = UIColor.yellow
            node2.size = ElementDual(x: .percent(0.3), y: .percent(0.9))
            node2.postion = ElementDual(x: .percent(0.7), y: .percent(0.1))
            node.addNode(node: node2)
        }
        self.show(v, sender: nil)
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
