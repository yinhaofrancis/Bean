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
            self.observer?.change(from: oldValue, to: self.state)
        }
    }
    private var observer:BeanObserver<T>?
    
    public init(wrappedValue:T){
        self.state = wrappedValue
    }
    public var projectedValue:BeanObserver<T>{
        if self.observer == nil{
            self.observer = BeanObserver()
        }
        return self.observer!
    }
}
