//
//  NodeStackLayout.swift
//  Bean
//
//  Created by hao yin on 2021/6/29.
//

import UIKit

public enum CrossAlign{
    case start
    case center
    case end
    case stretch
}
public enum AxisAlign{
    case start
    case center
    case end
    case between
    case around
    case evenly
}

public enum Axis{
    case vertical
    case horizontal
}

public protocol StackLayoutElement:DisplayElement{
    var basis:ElementDimension { get }
    var crossBasis:ElementDimension { get }
    var crossAlign:CrossAlign { get }
    var axisAlign:AxisAlign { get }
    var crossContentAlign: AxisAlign? { get }
    var alignSelf:CrossAlign? { get }
    var grow:CGFloat { get }
    var shrink:CGFloat { get }
    var wrap:Bool { get }
    var axis:Axis { get }
}

public class StackLayoutStyle:LayoutStyle{
    public func originSize(element: LayoutElement, parentElement: LayoutElement)->CGRect {
        var rect:CGRect
        if(parentElement.parentElement == nil){
            rect = parentElement.frame
        }else{
            rect = parentElement.parentElement!.layoutStyle.originSize(element: parentElement, parentElement: parentElement.parentElement!)
        }
        if parentElement.axis == .horizontal{
            let a = element.basis.issUnset ? 0 : element.basis.value(parent: rect.width)
            let c = element.basis.issUnset ? 0 : element.basis.value(parent: rect.height)
            return CGRect(x: 0, y: 0, width: a, height: c)
        }else{
            let a = element.basis.issUnset ? 0 : element.basis.value(parent: rect.height)
            let c = element.basis.issUnset ? 0 : element.basis.value(parent: rect.width)
            return CGRect(x: 0, y: 0, width: c, height: a)
        }
        
    }

    class StackLine:CustomDebugStringConvertible{
        var debugDescription: String{
            return "\(CGRect(x: basisPosition, y: crossPosition, width: basis, height: crossBasis))"
        }
        
        var array = Array<LayoutElement>()
        var basis:CGFloat = 0
        var crossBasis:CGFloat = 0
        var extraSpace:CGFloat = 0
        var basisPosition:CGFloat = 0
        var crossPosition:CGFloat = 0
        var itemGrowSum:CGFloat = 0
        var itemShrinkSum:CGFloat = 0
        init(array: Array<LayoutElement>, basis: CGFloat, crossBasis: CGFloat,extraSpace: CGFloat,itemGrowSum: CGFloat,itemShrinkSum:CGFloat){
            self.array = array
            self.basis = basis
            self.crossBasis = crossBasis
            self.extraSpace = extraSpace
            self.itemGrowSum = itemGrowSum
            self.itemShrinkSum = itemShrinkSum
        }
    }
    
    public func layout(elements: Array<LayoutElement>, parentElement:LayoutElement) {
        
        if(elements.count == 0){
            return
        }
        for i in elements {
            let frame = self.originSize(element: i, parentElement: parentElement)
            i.loadFrame(rect: frame)
        }
        for i in elements {
            i.layoutStyle.layout(elements: i.elements, parentElement: i)
        }
        let lines = self.seperateLine(elements: elements, parentElement: parentElement)
        self.layoutLine(lines: lines, parantElement: parentElement)
        if lines.count > 0{
            switch parentElement.axis {
            case .vertical:
                if(parentElement.crossBasis.issUnset){
                    parentElement.contentWidth = lines.max(by: {$0.crossBasis > $1.crossPosition})!.crossBasis
                }
                if(parentElement.basis.issUnset) {
                    parentElement.contentHeight = lines.max(by: {$0.basis > $1.crossPosition})!.basis
                }
                
            case .horizontal:
                if(parentElement.crossBasis.issUnset){
                    parentElement.contentHeight = lines.max(by: {$0.crossBasis > $1.crossPosition})!.crossBasis
                }
                if(parentElement.basis.issUnset) {
                    parentElement.contentWidth = lines.max(by: {$0.basis > $1.crossPosition})!.basis
                }
            }
        }
        
        for i in lines {
            self.layoutItem(line: i, parentElement: parentElement)
        }
    }
    func layoutItem(line:StackLine, parentElement:LayoutElement){
        var xStart:CGFloat = 0
        var xStep:CGFloat = 0
        let noUseSpace = ((line.itemGrowSum > 0 && line.extraSpace > 0) || (line.itemShrinkSum > 0 && line.extraSpace < 0)) ? 0:line.extraSpace
        switch parentElement.axisAlign {
        case .start:
            xStart = 0
            xStep = 0
            break
        case .center:
            xStart = noUseSpace / 2.0
            xStart = xStart < 0 ? 0 : xStart
            xStep = 0
            break
        case .end:
            xStart = noUseSpace
            xStart = xStart < 0 ? 0 : xStart
            xStep = 0
            break
        case .between:
            xStart = 0
            if(line.array.count > 1){
                xStep = noUseSpace / CGFloat(line.array.count - 1)
            }
            
            break
        case .around:
            xStart = noUseSpace / CGFloat(line.array.count * 2)
            xStart = xStart < 0 ? 0 : xStart
            xStep = xStart * 2
            break
        case .evenly:
            xStart = noUseSpace / CGFloat(line.array.count + 1)
            xStart = xStart < 0 ? 0 : xStart
            xStep = xStart
        }
        for i in 0 ..< line.array.count {
            let item = line.array[i]
            let align = item.alignSelf ?? parentElement.crossAlign
            let w = self.calcSize(line: line, item: item, parentElement: parentElement)
            let h = self.calcCrossSize(line: line, item: item, parentElement: parentElement, align: align)
            let x = xStart
            xStart = xStart + w.0 + xStep
            let ySpace = (align == .stretch && item.crossSizeDimension.issUnset) ? 0 : line.crossBasis - self.elementCrossSize(element: item, parentElement: parentElement)
            var y:CGFloat = 0
            switch align {
            
            case .start:
                y = 0
                break
            case .center:
                y = ySpace / 2
                break
            case .end:
                y = ySpace
                break
            case .stretch:
                y = 0
                break
            }
            switch parentElement.axis {
            
            case .vertical:
                item.loadFrame(rect: CGRect(x: y + line.crossPosition, y: x + line.basisPosition, width: h.0, height: w.0))
                if(w.1 || h.1){
                    item.layout()
                }
                break
            case .horizontal:
                item.loadFrame(rect: CGRect(x: x + line.basisPosition, y:y + line.crossPosition , width: w.0, height: h.0))
                if(w.1 || h.1){
                    item.layout()
                }
                break
            }
        }
    }
    required public init() {
        
    }
    
    func calcSize(line:StackLine,item:LayoutElement,parentElement:LayoutElement) -> (CGFloat,Bool){
        if item.basis.issUnset{
            if(line.extraSpace > 0 && line.itemGrowSum > 0){
                let a = ((item.grow / line.itemGrowSum) * line.extraSpace + self.elementAxisSize(element: item, parentElement: parentElement),true)
                print(a.0)
                return a
            }else if(line.extraSpace < 0 && line.itemShrinkSum > 0){
                return ((item.shrink / line.itemShrinkSum) * line.extraSpace + self.elementAxisSize(element: item, parentElement: parentElement),true)
            }else{
                return (self.elementAxisSize(element: item, parentElement: parentElement),false)
            }
        }else{
            return (self.elementAxisSize(element: item, parentElement: parentElement),false)
        }
        
    }
    func calcCrossSize(line:StackLine,item:LayoutElement,parentElement:LayoutElement,align:CrossAlign) -> (CGFloat,Bool){
        let h = (align == .stretch && item.crossBasis.issUnset) ? line.crossBasis : self.elementCrossSize(element: item, parentElement: parentElement)
        if(align == .stretch){
            return (h,true)
        }else{
            return (h,false)
        }
    }
    
    func layoutLine(lines:[StackLine],parantElement:LayoutElement) {
        if(lines.count == 0){
            return
        }
        var start:CGFloat = 0
        var step:CGFloat = 0
        var fill:Bool = false
        var lineExtra:CGFloat = 0
        let sum = lines.reduce(0) { r, l in
            l.crossBasis + r
        }
        let extraSpace = self.crossLimit(parentElement: parantElement) - sum
        switch parantElement.crossContentAlign {
        
        case .start:
            start = 0
            step = 0
            break
        case .center:
            step = 0
            start = extraSpace / 2
            break
        case .end:
            step = 0
            start = extraSpace
            break
        case .between:
            start = 0
            if(lines.count > 1){
                step = (self.crossLimit(parentElement: parantElement) - sum) / CGFloat((lines.count - 1))
            }else{
                step = 0
            }
            break
        case .around:
            start = extraSpace / CGFloat((lines.count * 2))
            step = start * 2
            break
        case .evenly:
            start = extraSpace / CGFloat((lines.count + 1))
            step = start
            break
        case .none:
            fill = true
            start = 0
            step = 0
            let lsum = lines.reduce(0) { r, l in
                l.crossBasis + r
            }
            lineExtra = self.crossLimit(parentElement: parantElement) - lsum
            break;
        }
        for i in 0 ..< lines.count {
            lines[i].crossPosition = start
            lines[i].basisPosition = 0
            
            if(fill && lineExtra > 0){
                lines[i].crossBasis += (lineExtra / CGFloat(lines.count))
                start += lines[i].crossBasis
                start += step
            }else{
                start += lines[i].crossBasis
                start += step
            }
        }
    }
    func axisLimit(parentElement:LayoutElement)->CGFloat{
        
        let size = parentElement.wrap ? parentElement.axisDisplaySize(axis: parentElement.axis) : CGFloat.infinity
        if size == 0 {
            if parentElement.basis.issUnset{
                return .infinity
            }
        }
        return size
    }
    func crossLimit(parentElement:LayoutElement)->CGFloat{
        parentElement.crossDisplaySize(axis: parentElement.axis)
    }
    func seperateLine(elements: Array<LayoutElement>, parentElement:LayoutElement) ->[StackLine]{
        let wlimit = self.axisLimit(parentElement: parentElement)
        if(wlimit == 0){
            return []
        }
        var sumV:CGFloat = 0
        var maxV:CGFloat = 0
        var growSum:CGFloat = 0
        var shrinkSum:CGFloat = 0
        var index = 0
        var lines:[StackLine] = []
        var items:[LayoutElement] = []
        while index < elements.count {
            let currentElement = elements[index]
            let s = self.elementAxisSize(element: currentElement, parentElement: parentElement)
            let h = self.elementCrossSize(element: currentElement, parentElement: parentElement)
            
            if(s + sumV > wlimit){
                if items.count == 0{
                    items.append(currentElement)
                    sumV = s
                    maxV = h
                    growSum = (currentElement.basis.issUnset == true ? currentElement.grow : 0)
                    shrinkSum = (currentElement.basis.issUnset == true ? currentElement.shrink : 0)
                    let wContainer = parentElement.axisDisplaySize(axis: parentElement.axis)
                    lines.append(StackLine(array: items, basis: sumV, crossBasis: maxV,extraSpace: wContainer - sumV,itemGrowSum: growSum,itemShrinkSum: shrinkSum))
                    items = Array()
                    maxV = 0
                    sumV = 0
                    growSum = 0
                    shrinkSum = 0
                }else{
                    let wContainer = parentElement.axisDisplaySize(axis: parentElement.axis)
                    lines.append(StackLine(array: items, basis: sumV, crossBasis: maxV,extraSpace: wContainer - sumV,itemGrowSum: growSum,itemShrinkSum: shrinkSum))
                    items = Array()
                    maxV = 0
                    sumV = 0
                    growSum = 0
                    shrinkSum = 0
                    items.append(currentElement)
                    maxV = max(maxV, h)
                    sumV += s
                    growSum += (currentElement.basis.issUnset == true ? currentElement.grow : 0)
                    shrinkSum += (currentElement.basis.issUnset == true ? currentElement.shrink : 0)
                }
            }else{
                items.append(currentElement)
                maxV = max(maxV, h)
                sumV += s
                growSum += (currentElement.basis.issUnset == true ? currentElement.grow : 0)
                shrinkSum += (currentElement.basis.issUnset == true ? currentElement.shrink : 0)
            }
            index += 1
        }
        if(items.count > 0){
            let wContainer = parentElement.axisDisplaySize(axis: parentElement.axis)
            lines.append(StackLine(array: items, basis: sumV, crossBasis: maxV,extraSpace: wContainer - sumV,itemGrowSum: growSum,itemShrinkSum: shrinkSum))
        }
        return lines
    }
    
    public func elementAxisSize(element:LayoutElement,parentElement:LayoutElement)->CGFloat{
        switch parentElement.axis {
        case .vertical:
            return element.axisSizeDimension.value(parent: parentElement.frame.height)
        case .horizontal:
            return element.axisSizeDimension.value(parent: parentElement.frame.width)
        }
    }
    public func elementCrossSize(element:LayoutElement,parentElement:LayoutElement)->CGFloat{
        switch parentElement.axis {
        case .vertical:
            return element.crossSizeDimension.value(parent: parentElement.frame.width)
        case .horizontal:
            return element.crossSizeDimension.value(parent: parentElement.frame.height)
        }
    }
}
