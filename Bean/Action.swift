//
//  Action.swift
//  Bean
//
//  Created by hao yin on 2021/6/17.
//

import Foundation
import UIKit
@propertyWrapper
public class Action<T:UIControl>:NSObject{
    public var wrappedValue:T
    public init(wrappedValue:T){
        self.wrappedValue = wrappedValue
    }
    public func add(event:UIControl.Event,callback:@escaping (T?)->Void){
        let c = ActionCall<T>(event: event, callback: callback)
        self.set.append(c)
        self.wrappedValue.addTarget(c, action: #selector(ActionCall<T>.action(sender:event:)), for: event)
    }
    var set:Array<ActionCall<T>> = Array()
}
public class ActionCall<T:UIControl>{
    var event:UIControl.Event
    var callback:(T?)->Void
    public init(event:UIControl.Event,callback:@escaping (T?)->Void) {
        self.event = event
        self.callback = callback
    }
    @objc func action(sender:Any,event:UIControl.Event){
        self.callback(sender as? T)
    }
}
