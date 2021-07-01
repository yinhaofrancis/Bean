//
//  textViewController.swift
//  example
//
//  Created by wenyang on 2021/6/27.
//

import UIKit
import Combine
class textViewController: UIViewController {

    @IBOutlet weak var textView: textView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additiol setup after loading the view.
    }
 
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        self.textView.storage.addAttachment(attach: TextAttachment())
        print(textView.storage.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: self.textView.storage.length), options: .longestEffectiveRangeNotRequired, using: { a, r, e in
            print(a,r,e)
        }))
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
