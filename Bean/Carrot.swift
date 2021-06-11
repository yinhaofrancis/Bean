//
//  Carob.swift
//  Bean
//
//  Created by hao yin on 2021/6/11.
//

import Foundation

public enum SeedType{
    case singlton
    case normal
}
public protocol SeedContext{
    
}
public protocol Seed{
    associatedtype Model
    var model:Model { get }
    static var type:SeedType { get }
}

public class SeedBuket{
    public static var shared:SeedBuket = SeedBuket()
    
    public var seeds:[String:Any] = [:]
    
    public func addSeed<T:Seed>(type:T.Type,name:String){
        pthread_rwlock_wrlock(self.rwlock)
        seeds[name] = type
        pthread_rwlock_unlock(self.rwlock)
    }
    public func addSeed<T:Seed>(type:T.Type){
        self.addSeed(type: type, name: "\(type)")
    }
    var rwlock:UnsafeMutablePointer<pthread_rwlock_t> = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
    init() {
        pthread_rwlock_init(self.rwlock, nil)
    }
    deinit {
        pthread_rwlock_destroy(self.rwlock)
        self.rwlock.deallocate()
    }
}

//@propertyWrapper
//public class Carrot<T:Seed>{
//
//}
