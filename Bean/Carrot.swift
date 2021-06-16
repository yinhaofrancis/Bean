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
public protocol Seed:AnyObject{
    
    static var type:SeedType { get }
    
    static func create()->Seed
    
}


public class SeedBuket{
    
    public static var shared:SeedBuket = SeedBuket()
    
    public var seeds:[String:Seed.Type] = [:]
    
    public var sigltenObject:[String:Seed] = [:]
    
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
    
    func create<T:Seed>(name:String,type:T.Type)->T?{
        if nil == self.seeds[name]{
            self.addSeed(type: type, name: name)
        }
        guard let cls = self.seeds[name] as? T.Type else {
            return nil
        }
        
        if cls.type == .singlton{
            if let obj = self.sigltenObject[name]{
                return obj as? T
            }else{
                return self.createSiglton(cls: cls, name: name)
            }
        }else{
            return cls.create() as? T
        }
    }
    
    private func createSiglton<T:Seed>(cls:T.Type,name:String)->T{
        let obj = cls.create()
        self.sigltenObject[name] = obj
        return obj as! T
    }
}

@propertyWrapper
public struct Mount<T:Seed>{
    
    public var name:String
    
    public var wrappedValue:T? {
        
        return SeedBuket.shared.create(name: self.name,type: T.self)
        
    }
    public init(name:String = "\(T.self)") {
        
        self.name = name
        
    }
}
