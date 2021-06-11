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


class ViewController: UIViewController {

    
    @Bean(name: "Model")
    var model:Model?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.model)
        $model.setState(state: Model(name: "a", uid: "a", count: Int(arc4random())))
        print(self.model)
        $model.observer = BeanObserver(callback:{ a , b in
            print("------")
            print(a,b)
            print("------")
        })
        // Do any additional setup after loading the view.
    }


}

