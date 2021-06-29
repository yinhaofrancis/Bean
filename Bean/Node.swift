//
//  Layout.swift
//  Bean
//
//  Created by WY on 2021/6/18.
//

import Foundation
import UIKit



public protocol DisplayWrap{
    var layer:CALayer { get }
    var view:UIView? { get }
    var isRespond:Bool { get }
}

extension UIView:DisplayWrap{
    public var view: UIView?{
        return self
    }
    public var isRespond: Bool{
        true
    }
}





public class Node<View:DisplayWrap,Style:LayoutStyle>:LayoutElement{
    
    
    
    public private (set) var view:View
    
    public override var frame: CGRect{
        didSet{
            self.view.view?.frame = frame
            self.view.layer.frame = frame
        }
    }
    public override var contentWidth: ElementDimension{
        self.view.view?.sizeToFit()
        if self.view.isRespond{
            let s = self.view.view?.frame.width ?? 0
            return s == 0 ? .unset : .pt(s)
        }else{
            return .unset
        }
    }
    public override var contentHeight: ElementDimension{
        self.view.view?.sizeToFit()
        if self.view.isRespond{
            let s = self.view.view?.frame.height ?? 0
            return s == 0 ? .unset : .pt(s)
        }else{
            return .unset
        }
    }
    public init(view:View){
        self.view = view
        super.init()
        self.layoutStyle = Style()
    }    
    public func addNode<V:DisplayWrap,S:LayoutStyle>(node:Node<V,S>){
        if self.view.isRespond && node.view.isRespond{
            self.view.view?.addSubview(node.view.view!)
        }else{
            self.view.layer.addSublayer(node.view.layer)
        }
        self.addLayoutElement(element: node)
    }
    public func insert(node:Node,below:Node){
        if self.view.isRespond{
            guard let nv = node.view.view , let bv = below.view.view else { return }
            self.view.view?.insertSubview(nv, belowSubview: bv)
        }else{
            self.view.layer.insertSublayer(node.view.layer, below: below.view.layer)
        }
        self.insert(element: node, below: below)
    }
    public func insert(node:Node,above:Node){
        if self.view.isRespond{
            guard let nv = node.view.view , let bv = above.view.view else { return }
            self.view.view?.insertSubview(nv, aboveSubview: bv)
        }else{
            self.view.layer.insertSublayer(node.view.layer, above: above.view.layer)
        }
        self.insert(element: node, above: above)
    }
    public func insert(node:Node,index:Int){
        if self.view.isRespond{
            guard let nv = node.view.view else { return }
            node.view.view?.insertSubview(nv, at: index)
        }else{
            self.view.layer.insertSublayer(node.view.layer, at: UInt32(index))
        }
        self.insert(element: node, index: index)
    }
    public func removeFromSuperNode(){
        self.view.view?.removeFromSuperview()
        self.view.layer.removeFromSuperlayer()
        self.removeFromSuperElement()
    }
}

open class NodeController<View:DisplayWrap,Style:LayoutStyle>:UIViewController{
    
    public typealias Build = (Node<View,Style>)->Void
    
    
    public private(set) var node:Node<View,Style>
    
    private var buildBlock:Build?
    
    
    public convenience init() where View == UIView{
        self.init(node:Node<UIView,Style>(view: UIView()))
    }
    public init(node:Node<View,Style>){
        self.node = node
        super.init(nibName: nil, bundle: nil)
    }
    public override func loadView() {
        self.view = self.node.view.view
    }
    public required init?(coder: NSCoder) where View == UIView  {
        self.node = Node<UIView,Style>(view: UIView())
        super.init(coder: coder)
    }
    public override func viewDidLoad() {
        
        self.buildBlock?(self.node)
        
        
    }
    
    public func nodeDidLoad(build:@escaping Build){
        self.buildBlock = build
        
    }
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.node.frame = self.view.frame
        self.node.postion = .zero
        self.node.size = .init(x: .pt(self.view.frame.size.width), y: .pt(self.view.frame.size.height))
        
        self.node.layout()
    }
}

public typealias NodeViewController = NodeController


