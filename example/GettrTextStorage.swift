//
//  GettrTextStorage.swift
//  example
//
//  Created by wenyang on 2021/7/1.
//

import UIKit

public class GettrAttachment:NSTextAttachment{
    
    public var displayContent:UIView
    public var replaceText:NSAttributedString?
    public var range:NSRange = NSRange(location: 0, length: 0)
    public var frame:CGRect
    public var font:UIFont
    public var inherit:Bool
    public weak var textView:UITextView?
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        self.textView?.addSubview(displayContent)
        displayContent.frame = CGRect(x: imageBounds.origin.x, y: imageBounds.origin.y - imageBounds.height, width: imageBounds.width, height: imageBounds.height)
        return nil
    }
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        if frame != .zero{
            if(inherit){
                self.font = UIFont.systemFont(ofSize: lineFrag.height)
            }else{
                self.font = UIFont.systemFont(ofSize: frame.height)
            }
            return CGRect(x: 0, y: self.font.descender, width: frame.width, height: self.font.ascender - self.font.descender)
            
        }
        if(self.inherit){
            self.font = UIFont .systemFont(ofSize: lineFrag.size.height)
            return CGRect(x: 0, y: self.font.descender, width: self.font.pointSize, height: self.font.ascender - self.font.descender)
        }
        
        return CGRect(x: 0, y: self.font.descender, width: self.font.pointSize, height: self.font.ascender - self.font.descender)
    }
    public init(view:UIView,frame:CGRect = .zero){
        self.displayContent = view
        self.frame = frame
        self.font = UIFont.systemFont(ofSize: 16)
        self.inherit = true
        super.init(data: nil, ofType: nil)
    }
    public init(view:UIView,
                font:UIFont = UIFont.systemFont(ofSize: 16),
                inherit:Bool = true){
        self.displayContent = view
        self.frame = .zero
        self.font = font
        self.inherit = inherit
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder: NSCoder) {
        self.displayContent = UIView()
        self.frame = .zero
        self.font = UIFont.systemFont(ofSize: 16)
        self.inherit = true
        super.init(coder: coder)
    }
    public func remove(){
        self.displayContent.removeFromSuperview()
    }
}


public protocol GettrTextStorageProvider:AnyObject{
    func handle(storage:GettrTextStorage,
                originText:NSAttributedString,
                attachName:String)->GettrAttachment?
}

public struct TokenRegex{
    var regex:NSRegularExpression
    var name:String
}

open class GettrTextStorage:NSTextStorage{
    
    public private(set) var attachments:Set<GettrAttachment> = Set()
    
    public weak var provider:GettrTextStorageProvider?
    
    public private(set) var content = NSMutableAttributedString()
    
    public private(set) weak var textView:UITextView?
    
    public override var string: String{
        return self.content.string
    }
    public var typeAttribute:[NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize: 16)]
    
    public var tokenRegexMap:[String:TokenRegex] = [:]
    
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
        guard  let v = self.textView else {
            super.processEditing()
            return
        }
        self.addAttributes(self.typeAttribute, range: NSRange(location: 0, length: self.string.count))
        let aString = self.content
        let parsedAttributeString = NSMutableAttributedString()
        var checkEnd = false
        var range:NSRange = NSRange(location: 0, length: string.count)
        for (key,value) in self.tokenRegexMap{
            while let result = value.regex.firstMatch(in:aString.string, options: .reportCompletion, range: range) {
                let subAttrStr = aString.attributedSubstring(from: result.range)
                let header = aString.attributedSubstring(from: NSRange(location: range.location, length: result.range.location - range.location))
                parsedAttributeString.append(header)
                guard let attach = self.provider?.handle(storage: self, originText: subAttrStr, attachName: key) else {
                    range = NSRange(location: result.range.location + result.range.length, length: aString.length - result.range.location - result.range.length)
                    parsedAttributeString.append(subAttrStr)
                    continue
                }
                attach.textView = self.textView
                attach.replaceText = subAttrStr
                self.attachments.insert(attach)
                parsedAttributeString.append(NSAttributedString(attachment: attach))
                range = NSRange(location: result.range.location + result.range.length, length: aString.length - result.range.location - result.range.length)
                checkEnd = true
            }
        }
        if range.length > 0 && range.location > 0 && checkEnd == true{
            parsedAttributeString.append(aString.attributedSubstring(from: range))
        }
        if self.content.string != parsedAttributeString.string && parsedAttributeString.length > 0{
            let temp = self.content
            self.content = parsedAttributeString
            self.edited([.editedAttributes,.editedCharacters], range: NSRange(location: 0, length: temp.length), changeInLength: parsedAttributeString.length - temp.length)
        }
        if self.attachments != self.allAttachments{
            let all = self.allAttachments
            self.attachments.filter { i in
                !all.contains(i)
            }.forEach { i in
                i.remove()
            }
            self.attachments = self.allAttachments
        }
        
        super.processEditing()
    }
    public func configTextView(view:UITextView){
        view.textStorage.removeLayoutManager(view.layoutManager)
        self.addLayoutManager(view.layoutManager)
        self.textView = view
        view.typingAttributes = self.typeAttribute
    }
    public func append(_ attach: GettrAttachment) {
        self.append(NSAttributedString(attachment: attach))
        attach.textView = self.textView
        self.attachments.insert(attach)
    }
    public func insert(_ attach: GettrAttachment, at loc: Int) {
        self.insert(NSAttributedString(attachment: attach), at: loc)
        attach.textView = self.textView
        self.attachments.insert(attach)
    }
    public var allAttachments:Set<GettrAttachment>{
        var result:Set<GettrAttachment> = Set()
        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length), options: .reverse) { a, n, u in
            guard let att = a as? GettrAttachment else {
                return
            }
            result.insert(att)
        }
        return result
    }
    public func register(name:String,regex:NSRegularExpression){
        tokenRegexMap[name] = TokenRegex(regex: regex, name: name)
    }
}
