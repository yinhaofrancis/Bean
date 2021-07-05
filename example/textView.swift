//
//  textView.swift
//  example
//
//  Created by hao yin on 2021/6/27.
//

import UIKit

open class textView:UITextView,GettrTextStorageProvider{
    public func handle(storage: GettrTextStorage, originText: NSAttributedString, attachName: String) -> GettrAttachment {
        let label = UIButton(type: .system)
        let a = GettrAttachment(view: label)
        label .setAttributedTitle(originText, for: .normal)
        let size = label.sizeThatFits(CGSize(width: CGFloat.infinity, height: .infinity))
        a.frame = label.frame
        a.frame.size = size
        a.inherit = true
        return a
    }
    
    
    var storage = GettrTextStorage()
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.storage.configTextView(view: self)
        storage.provider = self
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        storage.register(name: "button2", regex: try! NSRegularExpression(pattern: "@\\S*(\\s|$)", options: []),attribute: [.foregroundColor:UIColor.red])
        
        storage.register(name: "button3", regex: try! NSRegularExpression(pattern: "\\[[^\\[\\]]*\\]", options: []))
        
        storage.register(name: "button4", regex: try! NSRegularExpression(pattern: "@\\S*\\s", options: []))
        self.storage.configTextView(view: self)
        storage.provider = self
    }
}
