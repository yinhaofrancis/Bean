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

    
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

    @IBAction func change(_ sender: Any) {
     
    }
    
}

public struct test:Segment{
    public typealias Body = <#type#>
    

    public typealias Body = Container
    
    var text1:String
    var text2:String
    public lazy var body:Body = {
        Container(frame: CGRect(x: 0, y: 0, width: 100, height: 100), children: [
            Text(text: self.text1 , font: .systemFont(ofSize: 10), color: UIColor.red, frame: CGRect(x: 0, y: 0, width: 20, height: 20)),
            Container(frame: CGRect(x: 0, y: 100, width: 100, height: 100), children: [
                Text(text: self.text1 , font: .systemFont(ofSize: 10), color: UIColor.red, frame: CGRect(x: 0, y: 0, width: 20, height: 20)),
                Text(text: self.text1 , font: .systemFont(ofSize: 10), color: UIColor.red, frame: CGRect(x: 0, y: 20, width: 20, height: 20)),
            ])
        ])
    }()

}
