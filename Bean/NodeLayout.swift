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
    case unset
    public static var zero = ElementDimension.pt(0)
    public var issUnset:Bool{
        switch self {
        case .unset:
            return true
        default:
            return false
        }
    }
    public func value(parent:CGFloat)->CGFloat{
        switch self {
        case let .percent(w):
            return w * parent
        case let .pt(w):
            return w
        case .unset:
            return 0
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
    
    
    func layout(elements: Array<LayoutElement>, parentElement:LayoutElement)

    func originSize(element:LayoutElement, parentElement:LayoutElement)->CGRect
    
    init()
}


public protocol LayoutContainer{
    associatedtype View:DisplayWrap
    associatedtype Style:LayoutStyle
    var layoutStyle:Style { get }
}

public protocol DisplayElement:AnyObject {
    func loadFrame(rect:CGRect)
    var contentWidth:CGFloat { get }
    var contentHeight:CGFloat { get }
}
// absolute
public protocol AbsoluteLayoutElement:DisplayElement{
    var size:ElementDual { get }
    var postion:ElementDual { get }
}



public class  AbsoluteLayoutStyle:LayoutStyle{
    public func originSize(element: LayoutElement, parentElement: LayoutElement)->CGRect {
        var parentRect:CGRect
        if(parentElement.parentElement == nil){
            parentRect = parentElement.frame
        }else{
            parentRect = parentElement.parentElement!.layoutStyle.originSize(element: parentElement, parentElement: parentElement.parentElement!)
        }
        let x = element.postion.x.value(parent: parentRect.width)
        let y = element.postion.y.value(parent: parentRect.height)
        let w = element.size.x.value(parent: parentRect.width)
        let h = element.size.y.value(parent: parentRect.height)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    public func layout(elements: Array<LayoutElement>, parentElement:LayoutElement) {
        if(elements.count == 0){
            return
        }
        for i in elements {
            i.loadFrame(rect: self.originSize(element: i, parentElement: parentElement))
            i.layoutStyle.layout(elements: i.elements, parentElement: i)
        }
    }
    required public init() {
        
    }
}






public class LayoutElement:AbsoluteLayoutElement,StackLayoutElement,Hashable{
    
    public var axis: Axis = .horizontal
    
    public var contentWidth: CGFloat = 0
    
    public var contentHeight: CGFloat = 0

    public var basis: ElementDimension = .unset
    
    public var crossBasis: ElementDimension  = .unset
    
    public var crossAlign: CrossAlign = .start
    
    public var axisAlign: AxisAlign = .start
    
    public var crossContentAlign: AxisAlign? = nil
    
    public var alignSelf: CrossAlign?
    
    public var grow: CGFloat = 1
    
    public var shrink: CGFloat = 0
    
    public var wrap: Bool = true
        
    public var size: ElementDual = .zero
    
    public var postion: ElementDual = .zero
    
    public var frame:CGRect = .zero
    
    public var layoutStyle: LayoutStyle = AbsoluteLayoutStyle()
    
    public weak var parentElement:LayoutElement?
    
    public var axisSizeDimension:ElementDimension{
        let ax = self.parentElement?.axis ?? .horizontal
        switch self.basis {
        case .unset:
            return ax != .horizontal ? .pt(self.contentHeight) : .pt(self.contentWidth)
        default:
            return self.basis
        }
    }
    
    public var crossSizeDimension:ElementDimension{
        let ax = self.parentElement?.axis ?? .horizontal
        switch self.crossBasis {
        case .unset:
            return ax == .horizontal ? .pt(self.contentHeight) : .pt(self.contentWidth)
        default:
            return self.crossBasis
        }
    }
    
    public func loadFrame(rect: CGRect) {
        if(self.frame != rect){
            self.frame = rect
        }
    }
    
    public private(set) var elements:Array<LayoutElement> = Array()
    
    public static func == (lhs: LayoutElement, rhs: LayoutElement) -> Bool {
        Unmanaged.passUnretained(lhs).toOpaque() == Unmanaged.passUnretained(rhs).toOpaque()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
    
    
    
    func addLayoutElement(element:LayoutElement){
        self.elements.append(element)
        element.parentElement = self
    }
    
    func insert(element:LayoutElement,below:LayoutElement){

        
        guard let index = self.index(element: below) else { return }
        self.elements.insert(element, at: index)
        element.parentElement = self
        
    }
    func insert(element:LayoutElement,above:LayoutElement){
        guard let index = self.index(element: above) else { return }
        if(index == self.elements.count - 1){
            self .addLayoutElement(element: element)
        }else{
            self.elements.insert(element, at: index + 1)
            element.parentElement = self
        }
    }
    public func insert(element:LayoutElement,index:Int){
        self.elements.insert(element, at: index)
        element.parentElement = self
        
    }
    
    func removeFromSuperElement(){
        guard let index = self.parentElement?.index(element: self) else { return }
        self.parentElement?.elements.remove(at: index)
    }
    func index(element:LayoutElement)->Array<LayoutElement>.Index?{
        let item = self.elements.firstIndex { e in
            e == self
        }
        return item
    }
    public func layout(){
        self.layoutStyle.layout(elements: self.elements, parentElement: self)
    }
    public func axisDisplaySize(axis:Axis)->CGFloat{
        switch axis {
        case .vertical:
            return frame.height
        case .horizontal:
            return frame.width
        }
    }
    public func crossDisplaySize(axis:Axis)->CGFloat{
        switch axis {
        case .vertical:
            return frame.width
        case .horizontal:
            return frame.height
        }
    }
}
