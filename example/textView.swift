//
//  textView.swift
//  example
//
//  Created by hao yin on 2021/6/27.
//

import UIKit

open class textView:UITextView{
    
    var storage = limitTextStorage()
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.storage.limit = 10
        self.textStorage.removeLayoutManager(self.layoutManager)
        self.storage.addLayoutManager(self.layoutManager)
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.storage.limit = 10
        self.textStorage.removeLayoutManager(self.layoutManager)
        self.storage.addLayoutManager(self.layoutManager)
    }
}

public class limitTextStorage:NSTextStorage{
    public var limit:Int = 0
    public var content = NSMutableAttributedString()
    public override func processEditing() {
        
        if (self.content.length > limit && limit > 0){
            let useLimit = self.checkBounceIsEmoji() ?  limit : limit + 1
            self.addAttributes([.backgroundColor:UIColor.red,.font:UIFont.systemFont(ofSize: 20)], range: NSRange(location: useLimit, length: self.length - useLimit))
            self.addAttributes([.backgroundColor:UIColor.white,.font:UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: useLimit))
        }
        super.processEditing()
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
    }
    func checkBounceIsEmoji()->Bool{
        if(self.content.length > self.limit){
            let current = self.content.string
            let sub = current[current.utf16.index(current.utf16.startIndex, offsetBy: self.limit - 1)..<current.utf16.index(current.utf16.startIndex, offsetBy: self.limit + 1)]
            if(sub.containsEmoji){
                return true
            }
            return false
        }else{
            return false
        }
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


