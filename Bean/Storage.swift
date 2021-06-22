//
//  Storage.swift
//  Bean
//
//  Created by hao yin on 2021/6/22.
//

import Foundation
import UIKit
public enum StorageType{
    case document
    case cache
    case temp
    case memmory
}


//public protocol Storage:Transform where Content: Storage {
//    
//    var type:StorageType { get } 
//    static func save(name:String,storage:Self)
//    static func read(name:String)->Self?
//    
//}
//
//
