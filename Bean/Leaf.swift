//
//  Leaf.swift
//  Bean
//
//  Created by hao yin on 2021/6/23.
//

import Foundation


public class Leaf:Seed{
    public static func type() -> SeedType {
        .singlton
    }
    
    public static func create() -> Seed {
        Leaf()
    }
    
    @State
    public var config:URLSessionConfiguration = .default
    
    @State
    public var header:[String:String] = [:]
    
    @State
    public var host:String = ""
    
    @State
    public var session:URLSession = URLSession(configuration: .default)
    
    init() {
        self.$session.addObserver(observer: StateObserver(callback: { (v,o) in
            o.invalidateAndCancel()
        }))
    }
    
}


public struct UrlTemplete:ExpressibleByStringLiteral{
    public typealias StringLiteralType = String
    public var template:StringLiteralType
    
    public var reg = try! NSRegularExpression(pattern: "\\{[A-Za-z0-9]+\\}", options: .caseInsensitive)
    public init(stringLiteral:StringLiteralType){
        self.template = stringLiteral
    }
    public func url(keyValue:[String:String])->StringLiteralType{
        var result = self.template
        let rag = reg.matches(in: result, options: .reportProgress, range: NSRange(location: 0, length: self.template.count))
        for i in rag {
            let range = self.template.index(self.template.startIndex, offsetBy: i.range.location)..<self.template.index(self.template.startIndex, offsetBy: i.range.location + i.range.length)
            let of = self.template[range]
            if(of.count > 2){
                let key = String(of[of.index(after: of.startIndex)...of.index(of.endIndex, offsetBy: -2)]);
                if let v = keyValue[key]{
                    result = result.replacingOccurrences(of: of, with: v, options: .caseInsensitive, range: nil)
                }
            }
        }
        return result
    }
}

public struct BasicTransform<T> {
    public static func translateString(data:Data)->T? where T == String{
        return T(data: data, encoding: .utf8)
    }
    public static func translate(data:Data,type:T.Type)->T? where T:Codable{
        do{
            return try JSONDecoder().decode(type, from: data)
        }catch{
            return nil
        }
    }
    
}

@propertyWrapper
public class Request<T>{
    public typealias Decode = (Data)->T?
    public typealias Observer = (T?,T?)->Void
    
    public var url:UrlTemplete
    public var method:String
    public var response:HTTPURLResponse?
    public var error:Error?
    @Carrot
    var leaf:Leaf?
    
    public var wrappedValue:T?{
        didSet{
            self.observer?(self.wrappedValue,oldValue)
        }
    }
    
    
    
    var observer:Observer?
    
    var translate:Decode
    
    public func addObserver(observer:@escaping Observer){
        self.observer = observer
    }
    public func removeObserver(){
        self.observer = nil
    }
    
    public init(url:UrlTemplete,method:String,translate:@escaping Decode = {BasicTransform.translate(data: $0,type: T.self)})  where T:Codable{
        self.url = url
        self.method = method
        self.translate = translate
    }
    public init(url:UrlTemplete,method:String,translate:@escaping Decode = {BasicTransform.translateString(data: $0)})  where T == String{
        self.url = url
        self.method = method
        self.translate = translate
    }
    public func makeRequest(param:[String:String])->URLRequest?{
        
        guard let leaf = self.leaf else { return nil }
        let urlString = self.url.url(keyValue: param)
        var component = URLComponents(string: urlString)
        component?.scheme = "https"
        component?.host = leaf.host
        guard let url = component?.url else { return nil }
        return URLRequest(url: url)
    }
    public func request(param:[String:String]){
        guard let req = self.makeRequest(param: param) else { return }
        self.leaf?.session.dataTask(with: req, completionHandler:{[self] data, res, e in
            guard let ht = res as? HTTPURLResponse else{
                return
            }
            self.response = ht
            self.error = e
            guard let dat = data else {self.wrappedValue = nil;return}
            self.wrappedValue = self.translate(dat)
        }).resume()
    }
    public var projectedValue:Request{
        return self
    }
}

@propertyWrapper
public class Get<T>:Request<T>{
    public init(url:UrlTemplete) where T:Codable{
        super.init(url:url,method:"get")
    }
    public override var wrappedValue:T?{
        get{
            super.wrappedValue
        }
        set{
            super.wrappedValue = newValue
        }
    }
    public override var projectedValue:Get{
        return self
    }
}


