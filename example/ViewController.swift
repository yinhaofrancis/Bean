//
//  ViewController.swift
//  example
//
//  Created by hao yin on 2021/6/11.
//

import UIKit
import Bean
public struct Model{
    var name:String
    var uid:String
    var count:Int
}

public class MModel:Seed{
    public static var type: SeedType = .strong
    
    public static func create() -> Seed {
        MModel()
    }
    
    var name:String = ""
}

public class mok:Seed{
    public static func create() -> Seed {
        mok()
    }
    
    public static var type: SeedType = .singlton
    
   
    
    var name:String = "asda"
    func call(){
        print(name);
    }
}

class ViewController: UIViewController {

    
    @Bean(name: "Model")
    var model:Model?
    @Carrot
    var mo:mok!
    
    @Carrot
    var mm:MModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._model.setState(state: Model(name: "dadas\(arc4random())", uid: "", count: 0))
        self.$model.setChange { a, b in
            print(a,b)
        }
        self.mo.name = "AAA \(arc4random())"
        self.mm?.name = "BBB \(arc4random())"
        print(self.mo.name)
        print(self.mm?.name)
    }
}
class ViewController2: UIViewController {

    
    @Bean(name: "Model")
    var model:Model?

    
    @Carrot
    var mo:mok!
    
    @Carrot
    var mm:MModel?
    
    @Action
    var btn:UIButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(btn)
        self.btn.frame = CGRect(x: 100, y: 100, width: 44, height:44);
        self.btn.setTitle("ANV", for: .normal)
        self.btn.backgroundColor = UIColor.red;
        self._btn.add(event: .touchUpInside) { a in
            print(a)
        }
        print(self.mo.name)
        print(self.mm?.name)
    }

    @IBAction func change(_ sender: Any) {
        self._model.setState(state: Model(name: "dadas\(arc4random())", uid: "", count: 0))
    }
    
}

