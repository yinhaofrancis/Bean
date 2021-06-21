////
////  Observer.swift
////  Bean
////
////  Created by hao yin on 2021/6/18.
////
//
import Foundation
import UIKit
import SwiftUI
//public enum UIComponetType{
//    case view
//    case constaint
//    case layoutGuide
//    case layer
//    case none
//}
//public protocol UIComponent{
//    var type:UIComponetType { get }
//
//}
//public protocol UIComponentSet{
//    associatedtype SetType
//    static func build(@UIBuilder builder:(SetType)->[UIComponent])->SetType
//
//}
//
//public protocol UIMutableConponent{
//    associatedtype SelfType
//    func setProperty<Value>(path:ReferenceWritableKeyPath<SelfType,Value>,value:Value)->SelfType
//    func callFuntion(call:(SelfType)->Void)->SelfType
//}
//
//extension UIView:UIComponentSet,UIMutableConponent,UIComponent{
//    public func callFuntion(call: (UIView) -> Void) -> UIView {
//        call(self)
//        return self
//    }
//    public func setProperty<Value>(path: ReferenceWritableKeyPath<UIView, Value>, value: Value) -> UIView {
//        self[keyPath: path] = value
//        return self
//    }
//
//    public typealias SelfType = UIView
//
//
//    public var type: UIComponetType{
//        return .view
//    }
//    public static func build(@UIBuilder builder:(UIView)->[UIComponent])->UIView{
//        let v = Self()
//        let components = builder(v)
//        components.filter { $0.type == .view }.forEach{v.addSubview($0 as! UIView)}
//        components.filter { $0.type == .layer}.forEach {v.layer.addSublayer($0 as! CALayer)}
//        components.filter { $0.type == .layoutGuide }.forEach { v.addLayoutGuide($0 as! UILayoutGuide)}
//        v.addConstraints(components.filter { $0.type == .constaint }.map {$0 as! NSLayoutConstraint})
//        return v
//    }
//
//}
//
//extension NSLayoutConstraint:UIComponent{
//    public var type: UIComponetType{
//        return .constaint
//    }
//}
//
//extension UILayoutGuide:UIComponent{
//    public var type: UIComponetType{
//        return .layoutGuide
//    }
//}
//extension CALayer:UIComponent{
//    public var  type: UIComponetType{
//        return .layer
//    }
//}
//
//extension Never:UIComponent{
//    public var type: UIComponetType {
//        return .none
//    }
//}
//extension NSError:UIComponent{
//    public var type: UIComponetType {
//        return .none
//    }
//}
//
//
//public typealias UIComponentObject = UIComponent & AnyObject
//
//@resultBuilder
//public struct UIBuilder{
//
//    public static func buildBlock(_ components: UIComponentObject...) -> [UIComponentObject] {
//        return buildArray(components)
//    }
//    public static func buildEither(first component: UIComponentObject) -> UIComponentObject {
//        return component
//    }
//    public static func buildEither(second component: UIComponentObject) -> UIComponentObject {
//        return component
//    }
//    public static func buildArray(_ components: [UIComponentObject]) -> [UIComponentObject] {
//        return components
//    }
//    public static func buildOptional(_ component: UIComponentObject?) -> UIComponentObject {
//        return component ?? NSError()
//    }
//}
//View




@dynamicMemberLookup @dynamicCallable
public class Layout<T:UIView>{
    
    public enum Axis{
        case horizontal
        case vertical
    }
    
    public enum Content{
        case start
        case center
        case end
        case between
        case arround
        case evenly
    }
    
    public enum align{
        case start
        case center
        case end
        case stretch
    }
    
    public var direction:Axis = .horizontal
    
    public var wrap:Bool = true
    
    public var justcontent:Content = .start
    
    public var itemAlign:align = .start
    
    public var layoutConstaints:[NSLayoutConstraint] = []
    
    public var layoutGuides:[UILayoutGuide] = []
    
    public var component:T
    
    public init(key:String? = nil) {
        self.component = T()
    }
    
    subscript<V>(dynamicMember dynamicMember:ReferenceWritableKeyPath<T,V>)->V{
        get{
            component[keyPath: dynamicMember]
        }
        set{
            component[keyPath: dynamicMember] = newValue
        }
    }
    
    public func set<V>(key:ReferenceWritableKeyPath<T,V>,value:V)->Self{
        self.component[keyPath: key] = value
        return self
    }
    
    public func set(call:()->Void)->Self{
        call()
        return self
    }
    
    func dynamicallyCall<V>(withKeywordArguments args:KeyValuePairs<ReferenceWritableKeyPath<T,V>, V>)->Self{
        for i in args{
            self.component[keyPath: i.key] = i.value
        }
        return self
    }
    
    func dynamicallyCall<V:UIView>(withArguments args:[V])->Self{
        for i in args{
            self.component.addSubview(i)
        }
        return self
    }
}
