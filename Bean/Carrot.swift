//
//  Carob.swift
//  Bean
//
//  Created by hao yin on 2021/6/11.
//

import Foundation

public enum SeedType{
    
    case singlton
    case strong
    case normal
    
}

public protocol Context{
    func of<T:Seed>(type:T.Type)->T?
}

public class WeakSeed<T:AnyObject>{
    
    weak var seed:T?
    
    init(seed:T){
        self.seed = seed
    }
}
public protocol SeedContext{
    
}
public protocol Seed:AnyObject{
    
    static func type()->SeedType
    
    static func create()->Seed
    
}


public class SeedBucket:Context{
    
    public static var shared:SeedBucket = SeedBucket()
    
    public var seeds:[String:Seed.Type] = [:]
    
    public var sigltenObject:[String:Seed] = [:]
    
    public var strongObject:[String:WeakSeed<AnyObject>] = [:]
    
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
    
    public func of<T:Seed>(type: T.Type) -> T? {
        self.create(name: "\(type)", type: type)
    }
    
    func create<T:Seed>(name:String,type:T.Type)->T?{
        pthread_rwlock_rdlock(self.rwlock)
        if nil == self.seeds[name]{
            pthread_rwlock_unlock(self.rwlock)
            self.addSeed(type: type, name: name)
        }else{
            pthread_rwlock_unlock(self.rwlock)
        }
        pthread_rwlock_rdlock(self.rwlock)
        guard let cls = self.seeds[name] as? T.Type else {
            pthread_rwlock_unlock(self.rwlock)
            return nil
        }
        pthread_rwlock_unlock(self.rwlock)
        if cls.type() == .singlton{
            if let obj = self.readSiglton(name: name,type:type){
                return obj
            }else{
                return self.createSiglton(cls: cls, name: name)
            }
        }else if cls.type() == .strong{
            if let obj = self.readStrong(name: name, type: type){
                return obj
            }else{
                return self.createStrong(cls: cls, name: name)
            }
        }
        else{
            return cls.create() as? T
        }
    }
    
    private func createSiglton<T:Seed>(cls:T.Type,name:String)->T{
        pthread_rwlock_wrlock(self.rwlock)
        let obj = cls.create()
        self.sigltenObject[name] = obj
        pthread_rwlock_unlock(self.rwlock)
        return obj as! T
    }
    private func createStrong<T:Seed>(cls:T.Type,name:String)->T{
        pthread_rwlock_wrlock(self.rwlock)
        let obj = cls.create()
        let ws = WeakSeed(seed: obj as AnyObject)
        self.strongObject[name] = ws
        pthread_rwlock_unlock(self.rwlock)
        return obj as! T
    }
    private func readSiglton<T:Seed>(name:String,type:T.Type)->T?{
        pthread_rwlock_rdlock(self.rwlock)
        let s = self.sigltenObject[name]
        pthread_rwlock_unlock(self.rwlock)
        return s as? T
    }
    
    private func readStrong<T:Seed>(name:String,type:T.Type)->T?{
        pthread_rwlock_rdlock(self.rwlock)
        let s = self.strongObject[name]?.seed
        pthread_rwlock_unlock(self.rwlock)
        return s as? T
    }
}

@propertyWrapper
public class Carrot<T:Seed>{
    
    public private(set) var name:String
    
    public private(set) var strongObject:T?
    
    public private(set) var bucket:SeedBucket
    
    public var wrappedValue:T? {
        
        if T.type() == .strong{
            if (self.strongObject != nil){
                return self.strongObject
            }else{
                self.strongObject = self.bucket.create(name: self.name,type: T.self);
                return self.strongObject
            }
        }else{
            return self.bucket.create(name: self.name,type: T.self)
        }
    }
    public init(name:String = "\(T.self)",bucket:SeedBucket = SeedBucket.shared) {
        self.name = name
        self.bucket = bucket
    }
    public var projectedValue:Carrot{
        return self
    }
}


public protocol Observer:AnyObject,Hashable{
    associatedtype State
    func onChange(state:State,old:State)
}
public class StateObserver<T>:Observer {
    public static func == (lhs: StateObserver<T>, rhs: StateObserver<T>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public typealias State = T
    private var callback:(T,T)->Void
    public func onChange(state: T,old:T) {
        self.callback(state,old)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    public init(callback:@escaping (T,T)->Void){
        self.callback = callback
    }
    private var id:String = UUID().uuidString
    
}

@propertyWrapper
public class State<O:Observer,T> where O.State == T{
    public var wrappedValue:T{
        didSet{
            for i in self.set{
                i.onChange(state: wrappedValue,old: oldValue)
            }
        }
    }
    public init(wrappedValue:T,type:O.Type = StateObserver<T>.self) where O == StateObserver<T>{
        self.wrappedValue = wrappedValue
        self.set = []
        pthread_mutex_init(self.lock, nil)
    }
    
    public var set:Array<O>
    
    private var lock:UnsafeMutablePointer<pthread_mutex_t> = .allocate(capacity: 1)
    
    public func addObserver(observer:O){
        pthread_mutex_lock(self.lock)
        self.set.append(observer)
        pthread_mutex_unlock(self.lock)
    }
    public func removeObserver(observer:O){
        pthread_mutex_lock(self.lock)
        self.set.append(observer)
        pthread_mutex_unlock(self.lock)
    }
    public var projectedValue:State{
        return self
    }
    deinit {
        pthread_mutex_destroy(self.lock)
        self.lock.deallocate()
    }
}

