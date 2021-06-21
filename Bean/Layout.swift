//
//  Layout.swift
//  Bean
//
//  Created by hao yin on 2021/6/18.
//

import Foundation
import UIKit


public protocol Segment {
        
    associatedtype Body
    var body:Self.Body { get }
}


public struct Leaf:Segment{
    public typealias Body = Leaf
    public var body: Leaf {
        return self
    }
    public init() {}
}

public struct Text:Segment{
    
    public typealias Body = Leaf
    public var body: Leaf = Leaf()
    public var text:String
    public var font:UIFont
    public var color:UIColor
    
    public init(text:String,font:UIFont,color:UIColor,frame:CGRect){
        self.text = text
        self.font = font
        self.color = color
    }
    
}

public struct Frame<T:Segment>:Segment{
    public var body: T
    
    public typealias Body = T
    
    public var frame: CGRect
    
    public init(frame:CGRect,child:T){
        self.frame = frame
        self.body = child
    }
}
public struct Container:Segment{
    public typealias Body = Leaf
    public var body: Leaf = Leaf()
    public var children:[Any]
    public init() {
        
    }
    
}
