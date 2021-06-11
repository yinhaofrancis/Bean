//
//  Bean.swift
//  Bean
//
//  Created by hao yin on 2021/6/9.
//

import Foundation

public class WeakBean<T:AnyObject>{
    
    weak var bean:T?
}
public class Container{
    private var lock:UnsafeMutablePointer<pthread_mutex_t> = UnsafeMutablePointer.allocate(capacity: 1)
    public static var shared:Container = Container()
    public func query<T>(name:String,type:T.Type)->Pods<T>{
        pthread_mutex_lock(self.lock)
        let name = name
        var pod = self.dictionary[name] as? Pods<T>
        if(pod == nil){
            pod = Pods<T>()
            self.dictionary[name] = pod
        }
        pthread_mutex_unlock(self.lock)
        return pod!
    }
    init() {
        pthread_mutex_init(self.lock, nil)
    }
    deinit {
        pthread_mutex_destroy(self.lock)
    }
    public var dictionary:[String:Any] = [:]
}
public class Pods<T>{
    private var lock:UnsafeMutablePointer<pthread_mutex_t> = UnsafeMutablePointer.allocate(capacity: 1)
    public var content:T?{
        didSet{
            for i in beans {
                guard let ob = i.bean?.observer else { continue }
                i.bean?.queue.async {
                    ob.change(from: oldValue, to: self.content)
                }
            }
            pthread_mutex_lock(self.lock)
            self.beans = self.beans.filter { i in
                i.bean != nil
            }
            pthread_mutex_unlock(self.lock)
        }
    }
    public var beans:Array<WeakBean<Bean<T>>> = Array()
    public init() {
        pthread_mutex_init(self.lock, nil)
    }
    deinit {
        pthread_mutex_destroy(self.lock)
    }
}
public class BeanObserver<T>{

    public typealias Callback = (T?,T?)->Void
    public func setChange(call:@escaping Callback){
        self.call = call
    }
    public var call:Callback?
    public func change(from:T?,to:T?)->Void{
        self.call?(from,to)
    }
    public init(callback:Callback? = nil) {
        self.call = callback;
    }
}

@propertyWrapper
public class Bean<T>{
    public private(set) var name:String
    public var wrappedValue:T? {
        get{
            return pods.content
        }
    }
    public func setState(state:T?){
        self.pods.content = state
    }
    public var pods:Pods<T>
    var queue:DispatchQueue
    public var observer:BeanObserver<T>?
    public init(name:String,queue:DispatchQueue = DispatchQueue.main) {
        self.name = name
        self.pods = Container.shared.query(name: self.name, type: T.self)
        let wb = WeakBean<Bean<T>>()
        self.queue = queue
        wb.bean = self
        self.pods.beans.append(wb)
        print("pods :", Unmanaged.passUnretained(self.pods).toOpaque())
        print("ws   :", Unmanaged.passUnretained(wb).toOpaque())
        print("self :", Unmanaged.passUnretained(self).toOpaque())
        print("beans:", self.pods.beans)
        print("pods count:",self.pods.beans.count)
    }
    public var projectedValue:Bean<T>{
        return self
    }
}
