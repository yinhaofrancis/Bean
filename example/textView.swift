//
//  textView.swift
//  example
//
//  Created by hao yin on 2021/6/27.
//

import UIKit

open class textView:UITextView{
    
    var storage = PostTextStorage()
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.storage.limit = 10
        self.textStorage.removeLayoutManager(self.layoutManager)
        self.storage.addLayoutManager(self.layoutManager)
        self.typingAttributes = self.storage.defaultAttribute
        
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.storage.limit = 20
        self.textStorage.removeLayoutManager(self.layoutManager)
        self.typingAttributes = self.storage.defaultAttribute
        self.storage.addLayoutManager(self.layoutManager)
    }
}

public class PostTextStorage:NSTextStorage{
    public var limit:Int = 0
    public var content = NSMutableAttributedString()
    public var defaultAttribute:[NSAttributedString.Key:Any] = [
        .font:UIFont.systemFont(ofSize: 16),
        .foregroundColor:UIColor.gray
    ]
    public var atRegex:NSRegularExpression = try! NSRegularExpression(pattern: "(\\s|^)@\\S*(\\s|$)", options: .caseInsensitive)
    public var groupRegex:NSRegularExpression = try! NSRegularExpression(pattern: "(\\s|^)#\\S*(\\s|$)", options: .caseInsensitive)
    public override func processEditing() {
//        guard let tv = self.textView else { return  }
//        if (self.string.count > limit && limit > 0){
//            let useLimitIndex = self.string.index(self.string.startIndex, offsetBy: limit)
//            let useLimit = useLimitIndex.utf16Offset(in: self.string)
//            var att = tv.typingAttributes
//            att[.backgroundColor] = UIColor.red
//            self.addAttributes(att, range: NSRange(location: useLimit, length: self.length - useLimit))
//            att = tv.typingAttributes
//            att[.backgroundColor] = UIColor.clear
//            self.addAttributes(att, range: NSRange(location: 0, length: useLimit))
//        }
        self.setAttributes(self.defaultAttribute, range: NSRange(location: 0, length: self.string.count))
        NSTextAttachmentContainer
        self.loadHighlight(reg: atRegex, attribute: [.foregroundColor:UIColor.blue])
        self.loadHighlight(reg: groupRegex, attribute: [.foregroundColor:UIColor.green])
        super.processEditing()
    }
    public func loadHighlight(reg:NSRegularExpression,attribute:[NSAttributedString.Key:Any]){
        let result = reg.matches(in: self.string, options: .reportCompletion, range: NSRange(location: 0,length: self.string.count))
        
        for i in result{
            self.setAttributes(attribute, range: i.range)
        }
    }
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
}
extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}
extension Substring{
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}
extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}


