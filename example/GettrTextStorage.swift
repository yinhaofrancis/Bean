//
//  GettrTextStorage.swift
//  example
//
//  Created by wenyang on 2021/7/1.
//

import UIKit


public class GettrAttachment:NSTextAttachment{
    
    
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        
    }
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
    }
}


open class GettrTextStorage:NSTextStorage{
    
    public private(set) var content = NSMutableAttributedString()
    
    public private(set) weak var textView:UITextView?
    
    public override var string: String{
        return self.content.string
    }
    
    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        self.content.attributes(at: location, effectiveRange:range)
    }
    
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {

        self.beginEditing()
        self.content .setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }
    
    public override func replaceCharacters(in range: NSRange, with str: String) {
        self.beginEditing()
        self.content.replaceCharacters(in: range, with: str)
        self.edited(.editedCharacters, range: range, changeInLength: str.utf16.count - range.length)
        self.endEditing()
        print(str)
    }
    open override func processEditing() {
        self.setAttributes(self.textView?.typingAttributes, range: NSRange(location: 0, length: self.string.count))
        super.processEditing()
    }
    public func configTextView(view:UITextView){
        view.textStorage.removeLayoutManager(view.layoutManager)
        self.addLayoutManager(view.layoutManager)
        self.textView = view
    }
    public override func append(_ attrString: NSAttributedString) {
        
    }
}
