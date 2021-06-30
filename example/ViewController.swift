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
        let v = NodeViewController<UIView,AbsoluteLayoutStyle>()
        v.nodeDidLoad { n in
            n.view.backgroundColor = UIColor.white
            let node = Node<UIView, StackLayoutStyle>(view: UIView())
            node.view.view?.backgroundColor = UIColor.systemPink
            node.crossAlign = .end
//            node.crossContentAlign =
            
            node.axisAlign = .evenly
            node.size = ElementDual(x: .percent(0.8), y: .percent(0.8))
            node.postion = ElementDual(x: .percent(0.1), y: .percent(0.1))
            n.addNode(node: node)
            let node2 = Node<UIView, AbsoluteLayoutStyle>(view: UIView())
            node2.view.view?.backgroundColor = UIColor.yellow
            node2.basis = .pt(20)
            node2.crossBasis = .pt(30)
            node.addNode(node: node2)
            
            for i in 0 ..< 13{
                let noden = Node<UIView, AbsoluteLayoutStyle>(view: UIView())
                noden.view.view?.backgroundColor = UIColor.gray
                noden.basis = .pt(20)
                noden.crossBasis = .pt(30)
                node.addNode(node: noden)
            }
            
            
            let node3 = Node<UIView, AbsoluteLayoutStyle>(view: UIView())
            node3.view.view?.backgroundColor = UIColor.green
            node3.basis = .unset
            node3.crossBasis = .pt(70)
            
            node.addNode(node: node3)
            
            let node4 = Node<UIView, StackLayoutStyle>(view: UIView())
            node4.view.view?.backgroundColor = UIColor.green
            node4.grow = 0
            node.addNode(node: node4)
            
            
            let node41 = Node<UIView,AbsoluteLayoutStyle>(view: UIView())
            node41.view.view?.backgroundColor = UIColor.black
            node41.basis = .pt(20)
            node41.crossBasis = .pt(30)
            node4.addNode(node: node41)
            let node42 = Node<UIView, AbsoluteLayoutStyle>(view: UIView())
            node42.view.view?.backgroundColor = UIColor.gray
            node42.basis = .pt(30)
            node42.crossBasis = .pt(40)
            node4.addNode(node: node42)
            
            
            let node43 = Node<UIView, AbsoluteLayoutStyle>(view: UIView())
            node43.view.view?.backgroundColor = UIColor.yellow
            node43.basis = .pt(30)
            node43.crossBasis = .pt(50)
            node4.addNode(node: node43)
        }
        self.showDetailViewController(v, sender: nil)
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
