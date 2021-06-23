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
    public var session:URLSessionConfiguration = .default
}


public struct UrlTemplete:ExpressibleByStringLiteral{
    public typealias StringLiteralType = String
    public var template:StringLiteralType
    
    public var reg = try! NSRegularExpression(pattern: "\\{[A-Za-z0-9]+\\}", options: .caseInsensitive)
    public init(stringLiteral:StringLiteralType){
        self.template = stringLiteral
    }
}
