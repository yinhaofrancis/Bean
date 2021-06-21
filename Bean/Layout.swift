//
//  Layout.swift
//  Bean
//
//  Created by hao yin on 2021/6/18.
//

import Foundation
import QuartzCore
public protocol Fragment{
    
    associatedtype Body:Fragment
    
    var body:Self.Body { get }
    
}

public protocol Container{
    
    associatedtype Body:Fragment
    
    var body:[Self.Body] { get }
    
}
public protocol ConstaintItem{
    var constaint:Constaint { get }
    func addConstaint(constaint:Constaint)
    func removeConstaint(constaint:Constaint)
    var superItem:ConstaintItem? { get }
    var childItem:[ConstaintItem] { get }
    var shouldLayout:Bool { get }
    var frame:CGRect { get }
    func locateValue(archor:Archor)->CGFloat
    func layout()
    var growX:CGFloat { get }
    var growY:CGFloat { get }
    var shrinkX:CGFloat { get }
    var shrinkY:CGFloat { get }
}

extension ConstaintItem{
    public var left:Archor { Archor(item: self, att: .left) }
    public var right:Archor { Archor(item: self, att: .right) }
    public var top:Archor { Archor(item: self, att: .top) }
    public var bottom:Archor { Archor(item: self, att: .bottom) }
    public var centerX:Archor { Archor(item: self, att: .centerX) }
    public  var centerY:Archor { Archor(item: self, att: .centerY) }
    public var width:Archor { Archor(item: self, att: .width) }
    public var heigth:Archor { Archor(item: self, att: .heigth) }
}


public enum ConstaintAttribute{
    case left
    case right
    case top
    case bottom
    case centerX
    case centerY
    case width
    case heigth
}
public enum ConstaintRelate{
    case Equel
    case GreatEquel
    case LessEqual
}
public class Archor{
    var item:ConstaintItem
    var att:ConstaintAttribute
    init(item:ConstaintItem,att:ConstaintAttribute){
        self.item = item
        self.att = att
    }
}

public class Constaint{
    public var lhs:Archor
    public var rhs:Archor?
    public var relate:ConstaintRelate
    public var multi:CGFloat
    public var contant:CGFloat
    public var priority:CGFloat = 1000
    var needLayout:Bool = true
    public init(lhs:Archor,relate:ConstaintRelate,multi:CGFloat,rhs:Archor,constant:CGFloat){
        self.lhs = lhs
        self.relate = relate
        self.multi = multi
        self.rhs = rhs
        self.contant = constant
    }
}
