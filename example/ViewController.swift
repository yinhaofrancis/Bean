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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.$model.setState(state: Model(name: "dadas\(arc4random())", uid: "", count: 0))
        self.$model.observer = BeanObserver(callback: { a, b in
            print(a,b)
        })
    }


}
class ViewController2: UIViewController {

    
    @Bean(name: "Model")
    var model:Model?
    @Carrot
    var mo:mok!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.model?.name)
    }

    @IBAction func change(_ sender: Any) {
        self.$model.setState(state: Model(name: "dadas\(arc4random())", uid: "", count: 0))
    }
    
}

