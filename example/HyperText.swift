//
//  HyperText.swift
//  example
//
//  Created by hao yin on 2021/7/1.
//

import UIKit


public class TextAttachment:NSTextAttachment{
    public weak var textView:UITextView?
    public var font:UIFont = UIFont.systemFont(ofSize: 16)
    public var rect:CGRect = .zero
    public var display:UIView
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        self.font = UIFont.systemFont(ofSize: lineFrag.height)
        return self.displaySize
    }
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        self.textView?.addSubview(self.display)
        display.frame = CGRect(x: imageBounds.origin.x, y: imageBounds.origin.y - imageBounds.size.height, width: imageBounds.width, height: imageBounds.height)
        return nil
    }
    public init(rect:CGRect = .zero) {
        self.rect = rect
        self.display = UIView()
        self.display.backgroundColor = UIColor(red: 0, green: CGFloat((arc4random() % 100)) / 100.0, blue: 0, alpha: 1)
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder: NSCoder) {
        self.display = UIView()
        self.display.backgroundColor = UIColor(red: 0, green: CGFloat((arc4random() % 100)) / 100.0, blue: 0, alpha: 1)
        super.init(coder: coder)
    }
    deinit {
        self.display.removeFromSuperview()
    }
    public func remove(){
        self.display.removeFromSuperview()
    }
    public var displaySize:CGRect{
        if(self.rect == .zero){
            print(font.ascender,font.descender)
            return CGRect(x: 0, y: self.font.descender, width: self.font.pointSize, height: self.font.ascender - self.font.descender)
        }else{
            return self.rect
        }
    }
}
