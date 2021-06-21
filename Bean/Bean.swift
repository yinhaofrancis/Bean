//
//  Bean.swift
//  Bean
//
//  Created by hao yin on 2021/6/9.
//

import Foundation


public class BeanContainer{
    private var lock:UnsafeMutablePointer<pthread_mutex_t> = UnsafeMutablePointer.allocate(capacity: 1)
    public static var shared:BeanContainer = BeanContainer()
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
                guard let ob = i.observer else { continue }
                i.queue.async {
                    ob.change(from: oldValue, to: self.content)
                }
            }
        }
    }
    public var beans:Array<Bean<T>> = Array()
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
        self.pods = BeanContainer.shared.query(name: self.name, type: T.self)
        let wb = Bean<T>(name: name)
        self.queue = queue
        self.pods.beans.append(wb)
    }
    public var projectedValue:BeanObserver<T>{
        if self.observer == nil{
            self.observer = BeanObserver()
        }
        return self.observer!
    }
}
