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
        self.text.text = self.state?.mm
        self.state?.$mm.observer = BeanObserver(handle: { [weak self] v in
            self?.text.text = v
        })
    }

    @IBAction func change(_ sender: Any) {
     
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
    
    @Request<String,String,String,String,BeanObserver<String>>(url: "https://www.baidu.com")
    var str:String?
    
    @Get<String,String,BeanObserver<String>>(url: "https://www.baidu.com")
    var mm:String?
}
