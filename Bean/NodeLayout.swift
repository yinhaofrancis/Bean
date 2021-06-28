//
//  ElementLayout.swift
//  Bean
//
//  Created by WY on 2021/6/28.
//

import UIKit
public enum ElementDimension{
    case pt(CGFloat)
    case percent(CGFloat)
    
    public static var zero = ElementDimension.pt(0)
    
    public func value(parent:CGFloat)->CGFloat{
        switch self {
        case let .percent(w):
            return w * parent
        case let .pt(w):
            return w
        }
    }
}

public struct ElementDual{
    public var x:ElementDimension
    public var y:ElementDimension
    
    public static var zero = ElementDual(x: .zero, y: .zero)
    
    public init(x:ElementDimension,y:ElementDimension){
        self.x = x
        self.y = y
    }
}


public protocol LayoutStyle{
    
    func layout(elements:Set<LayoutElement>,parentRect:CGRect)

    init()
}


public protocol LayoutContainer{
    associatedtype View:DisplayWrap
    associatedtype Style:LayoutStyle
    var layoutStyle:Style { get }
}

public protocol DisplayElement:AnyObject {
    func loadFrame(rect:CGRect)
}
// absolute
public protocol AbsoluteLayoutElement:DisplayElement{
    var size:ElementDual { get }
    var postion:ElementDual { get }
}

public class  AbsoluteLayoutStyle:LayoutStyle{
    public func layout(elements: Set<LayoutElement>, parentRect: CGRect) {
        for i in elements {
            let x = i.postion.x.value(parent: parentRect.width)
            let y = i.postion.y.value(parent: parentRect.height)
            let w = i.size.x.value(parent: parentRect.width)
            let h = i.size.y.value(parent: parentRect.height)
            i.loadFrame(rect: CGRect(x: x, y: y, width: w, height: h))
        }
    }
    required public init() {
        
    }
}

public class  RelateLayoutStyle:LayoutStyle{
    public func layout(elements: Set<LayoutElement>, parentRect: CGRect) {
        for i in elements {
            let x = i.postion.x.value(parent: parentRect.width)
            let y = i.postion.y.value(parent: parentRect.height)
            let w = i.size.x.value(parent: parentRect.width)
            let h = i.size.y.value(parent: parentRect.height)
            i.loadFrame(rect: CGRect(x: x, y: y, width: w, height: h))
        }
    }
    required public init() {
        
    }
}



public class LayoutElement:AbsoluteLayoutElement,Hashable{
        
    public var size: ElementDual = .zero
    
    public var postion: ElementDual = .zero
    
    public var frame:CGRect = .zero
    
    public var layoutStyle: LayoutStyle = AbsoluteLayoutStyle()
    
    public func loadFrame(rect: CGRect) {
        if(self.frame != rect){
            self.frame = rect
            self.layout()
        }
        
    }
    
    public private(set) var elements:Set<LayoutElement> = Set()
    
    public static func == (lhs: LayoutElement, rhs: LayoutElement) -> Bool {
        Unmanaged.passUnretained(lhs).toOpaque() == Unmanaged.passUnretained(rhs).toOpaque()
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
    
    
    public var parentElement:LayoutElement?
    
    
    
    
    func addLayoutElement(element:LayoutElement){
        self.elements.insert(element)
        element.parentElement = self

        self.layout()
    }
    func insert(element:LayoutElement,below:LayoutElement){

        self.addLayoutElement(element: element)
        
    }
    func insert(element:LayoutElement,above:LayoutElement){
        self.addLayoutElement(element: element)
    }
    public func insert(element:LayoutElement,index:Int){
        self.addLayoutElement(element: element)
    }
    func removeFromSuperElement(){
        self.elements.remove(self)
        self.parentElement?.layout()
    }
    public func layout(){
        self.layoutStyle.layout(elements: self.elements, parentRect: self.frame)
    }
}
