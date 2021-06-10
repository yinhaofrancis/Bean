//
//  Coconut.swift
//  Bean
//
//  Created by hao yin on 2021/6/10.
//

import Foundation

@propertyWrapper
public class Coconut<T>{
    public func setState(state:T){
        self.state = state
    }
    public var wrappedValue:T {
        get{
            self.state
        }
    }
    private var state:T{
        didSet{
            self.observer?.callback(oldValue,wrappedValue)
        }
    }
    public var observer:BeanObserver<T>?
    
    public init(wrappedValue:T){
        self.state = wrappedValue
    }
    public var projectedValue:Coconut<T>{
        return self
    }
}
