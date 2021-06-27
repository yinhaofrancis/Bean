//
//  textViewController.swift
//  example
//
//  Created by wenyang on 2021/6/27.
//

import UIKit

class textViewController: UIViewController {

    @IBOutlet weak var textView: textView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.storage.replaceCharacters(in: .init(location: 0, length: 0), with: "dsdsdsdsdsdsdsdsdsd")
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
