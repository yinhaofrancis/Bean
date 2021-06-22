//
//  Bean.swift
//  Bean
//
//  Created by hao yin on 2021/6/9.
//

import Foundation
import UIKit

public class HeaderState:Seed{
    public static func type() -> SeedType {
        .strong
    }
    
    public static func create() -> Seed {
        HeaderState()
    }
    
    public var state:[String:String] = [:]
}


public protocol Transform{

    associatedtype Content
    
    static func encode(target:Content)->Data?
    
    static func decode(data:Data)->Content?
    
}

public class JsonTransform<T:Codable>:Transform{
    public typealias Content = T
    
    public static func encode(target: T) -> Data? {
        return try? JSONEncoder().encode(target)
    }
    public static func decode(data: Data) -> T? {
        try? JSONDecoder().decode(T.self, from: data)
    }
}

public class ImageTransform:Transform{
    public static func encode(target: UIImage) -> Data? {
        target.jpegData(compressionQuality: 1)
    }
    
    public static func decode(data: Data) -> UIImage? {
        UIImage(data: data)
    }
    
    
    public typealias Content = UIImage
    
}


extension String:Transform{
    public static func encode(target: String) -> Data? {
        target.data(using: .utf8)
    }
    
    public static func decode(data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }
    
    public typealias Content = String
    
}
extension UIImage:Transform{
    public static func encode(target: UIImage) -> Data? {
        target.jpegData(compressionQuality: 1)
    }
    
    public static func decode(data: Data) -> UIImage? {
        UIImage(data: data)
    }
    
    public typealias Content = UIImage
    
    
}



public protocol Observer{
    
    associatedtype Value
    func handleValue(v:Value?)
}


public class BeanObserver<T>:Observer{
    public func handleValue(v: T?) {
        self.handle(v)
    }
    public init(handle:@escaping (T?)->Void){
        self.handle = handle
    }
    public var handle:(T?)->Void
    public typealias Value = T
        
}

public class Pod<Content,
                 ContentTransform:Transform,
                 PostContent,
                 PostTransform:Transform,
                 Ob:Observer>:Seed  where Ob.Value == Content,
                                          ContentTransform.Content == Content,
                                          PostTransform.Content == PostContent{
    
    public static func type() -> SeedType {
        return .strong
    }
        
    public static func create() -> Seed {
        Pod()
    }
    
    var urls:[WeakSeed<Request<Content,ContentTransform,PostContent,PostTransform,Ob>>] = []
    
    var content:Content?{
        didSet{
            self.urls.forEach { i in
                i.seed?.observer?.handleValue(v: content)
            }
        }
    }
}

extension URLSession:Seed{
    public static func type() -> SeedType {
        .singlton
    }
    
    public static func create() -> Seed {
        URLSession(configuration: .default)
    }
}

@propertyWrapper
public class Request<Content,
                     ContentTransform:Transform,
                     PostContent,
                     PostTransform:Transform,
                     Ob:Observer> where Ob.Value == Content,
                                        ContentTransform.Content == Content,
                                        PostTransform.Content == PostContent{
    
    public var url:URL
    
    public var method:String
    
    @Carrot
    var pod:Pod<Content,ContentTransform,PostContent,PostTransform,Ob>?
    
    @Carrot
    var session:URLSession?
    
    @Carrot
    var header:HeaderState?
    
    public var observer:Ob?
    
    public var queue:DispatchQueue?
    
    public var wrappedValue:Content?{
        get{
            if self.pod?.content == nil{
                self.request()
            }
            return self.pod?.content
        }
        set{
            self.pod?.content = newValue
        }
    }
    public func request(body:PostContent? = nil){
        var req = URLRequest(url: self.url)
        req.httpMethod = self.method
        if let b = body{
            req.httpBody = PostTransform.encode(target: b)
        }
        if let header = self.header{
            req.allHTTPHeaderFields = header.state
        }
        self.session?.dataTask(with: req, completionHandler: { data, resp, e in
            let q = self.queue ?? DispatchQueue.main
            q.async {
                guard let dat = data else { return }
                self.wrappedValue = ContentTransform.decode(data: dat)
            }
        }).resume()
    }
    
    
    
    public init(url:String,method:String = "get",queue:DispatchQueue? = nil) {
        
        self.url = URL(string: url)!
        
        self.method = method
        
        self.queue = queue
        
        if(wrappedValue != nil){
            self.wrappedValue = wrappedValue
        }
        self.pod?.urls.append(WeakSeed(seed: self))
        
    }
    public var projectedValue:Request{
        return self
    }
}

@propertyWrapper
public class Get<Content,ContentTransform:Transform,O:Observer>:Request<Content,ContentTransform,String,String,O> where ContentTransform.Content == Content , O.Value == Content{

    public override var wrappedValue:Content?{
        get{
            super.wrappedValue
        }
        set{
            super.wrappedValue = newValue
        }
    }
    
    public init(url:String,queue:DispatchQueue? = nil){
        super.init(url: url, method: "get", queue: queue)
    }
    public override var projectedValue:Get{
        return self
    }
}


@propertyWrapper
public class Json<Content:Codable,Body:Codable,O:Observer>:Request<Content,JsonTransform<Content>,Body,JsonTransform<Body>,O> where O.Value == Content{

    public override var wrappedValue:Content?{
        get{
            super.wrappedValue
        }
        set{
            super.wrappedValue = newValue
        }
    }
    
    public override init(url:String,method:String = "get",queue:DispatchQueue? = nil){
        super.init(url: url, method: method, queue: queue)
    }
    public override var projectedValue:Json{
        return self
    }
}

@propertyWrapper
public class GetJson<Content:Codable,O:Observer>:Request<Content,JsonTransform<Content>,String,String,O> where O.Value == Content{

    public override var wrappedValue:Content?{
        get{
            super.wrappedValue
        }
        set{
            super.wrappedValue = newValue
        }
    }
    
    public init(url:String,queue:DispatchQueue? = nil){
        super.init(url: url, method: "get", queue: queue)
    }
    public override var projectedValue:GetJson{
        return self
    }
}
@propertyWrapper
public class PostJson<Content:Codable,Body:Codable,O:Observer>:Request<Content,JsonTransform<Content>,Body,JsonTransform<Body>,O> where O.Value == Content{

    public override var wrappedValue:Content?{
        get{
            super.wrappedValue
        }
        set{
            super.wrappedValue = newValue
        }
    }
    
    public init(url:String,queue:DispatchQueue? = nil){
        super.init(url: url, method: "post", queue: queue)
    }
    public override var projectedValue:PostJson{
        return self
    }
}
@propertyWrapper
public class Image<O:Observer>:Request<UIImage,ImageTransform,String,String,O> where O.Value == UIImage{

    public override var wrappedValue:UIImage?{
        get{
            super.wrappedValue
        }
        set{
            super.wrappedValue = newValue
        }
    }
    
    public override init(url:String,method:String = "get",queue:DispatchQueue? = nil){
        super.init(url: url, method: method, queue: queue)
    }
    public override var projectedValue:Image{
        return self
    }
    
}
