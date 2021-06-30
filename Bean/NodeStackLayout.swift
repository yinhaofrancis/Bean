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

    struct StackLine{
        var array = Array<LayoutElement>()
        var basis:CGFloat = 0
        var crossBasis:CGFloat = 0
        var extraSpace:CGFloat = 0
        var basisPosition:CGFloat = 0
        var crossPosition:CGFloat = 0
        var itemGrowSum:CGFloat = 0
        var itemShrinkSum:CGFloat = 0
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
        var lines = self.seperateLine(elements: elements, parentElement: parentElement)
        lines = self.layoutLine(lines: lines, parantElement: parentElement)
        if lines.count > 0{
            switch parentElement.axis {
            case .vertical:
                if(parentElement.crossBasis.issUnset){
                    parentElement.contentWidth = .pt(lines.max(by: {$0.crossBasis > $1.crossPosition})!.crossBasis)
                }
                if(parentElement.basis.issUnset) {
                    parentElement.contentHeight = .pt(lines.max(by: {$0.basis > $1.crossPosition})!.basis)
                }
                
            case .horizontal:
                if(parentElement.crossBasis.issUnset){
                    parentElement.contentHeight = .pt(lines.max(by: {$0.crossBasis > $1.crossPosition})!.crossBasis)
                }
                if(parentElement.basis.issUnset) {
                    parentElement.contentWidth = .pt(lines.max(by: {$0.basis > $1.crossPosition})!.basis)
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
        let noUseSpace = ((line.itemGrowSum > 0 && line.extraSpace > 0) || (line.itemShrinkSum > 0 && line.extraSpace < 0)) ? line.extraSpace:0
        switch parentElement.axisAlign {
        case .start:
            xStart = 0
            xStep = 0
            break
        case .center:
            xStart = noUseSpace / 2.0
            xStep = 0
            break
        case .end:
            xStart = noUseSpace
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
            xStep = xStart * 2
            break
        case .evenly:
            xStart = noUseSpace / CGFloat(line.array.count + 1)
            xStep = xStart
        }
        for i in 0 ..< line.array.count {
            let item = line.array[i]
            let align = item.alignSelf ?? parentElement.crossAlign
            let w:CGFloat = self.calcSize(line: line, item: item, parentElement: parentElement)
            let h:CGFloat = (align == .stretch && item.crossSizeDimension.issUnset) ? line.crossBasis : self.elementCrossSize(element: item, parentElement: parentElement)
            let x = xStart
            xStart = xStart + w + xStep
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
                item.loadFrame(rect: CGRect(x: y + line.crossPosition, y: x + line.basisPosition, width: h, height: w))
                break
            case .horizontal:
                item.loadFrame(rect: CGRect(x: x + line.basisPosition, y:y + line.crossPosition , width: w, height: h))
                break
            }
        }
    }
    required public init() {
        
    }
    
    func calcSize(line:StackLine,item:LayoutElement,parentElement:LayoutElement) -> CGFloat{
        if item.axisSizeDimension.issUnset{
            return (line.extraSpace > 0 ? (item.grow / line.itemGrowSum) * line.extraSpace : (item.shrink / line.itemShrinkSum) * line.extraSpace) + self.elementAxisSize(element: item, parentElement: parentElement)
        }else{
            return self.elementAxisSize(element: item, parentElement: parentElement)
        }
        
    }
    
    func layoutLine(lines:[StackLine],parantElement:LayoutElement)->[StackLine] {
        if(lines.count == 0){
            return []
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
        var copyLines = lines
        for i in 0 ..< lines.count {
            copyLines[i].crossPosition = start
            copyLines[i].basisPosition = 0
            start += copyLines[i].crossBasis
            start += step
            if(fill && lineExtra > 0){
                copyLines[i].crossBasis += (lineExtra / CGFloat(lines.count))
            }
        }
        return copyLines
    }
    func axisLimit(parentElement:LayoutElement)->CGFloat{
        
        let size = parentElement.wrap ? (parentElement.axis == .horizontal ? parentElement.frame.width : parentElement.frame.height) : CGFloat.infinity
        if size == 0 {
            if parentElement.basis.issUnset{
                return .infinity
            }
        }
        return size
    }
    func crossLimit(parentElement:LayoutElement)->CGFloat{
        parentElement.axis != .horizontal ? parentElement.frame.width : parentElement.frame.height
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
                    growSum = currentElement.grow
                    shrinkSum = currentElement.shrink
                    lines.append(StackLine(array: items, basis: sumV, crossBasis: maxV,extraSpace: wlimit - sumV,itemGrowSum: growSum,itemShrinkSum: shrinkSum))
                    items = Array()
                    maxV = 0
                    sumV = 0
                    growSum = 0
                    shrinkSum = 0
                }else{
                    lines.append(StackLine(array: items, basis: sumV, crossBasis: maxV,extraSpace: wlimit - sumV,itemGrowSum: growSum,itemShrinkSum: shrinkSum))
                    items = Array()
                    maxV = 0
                    sumV = 0
                    growSum = 0
                    shrinkSum = 0
                    items.append(currentElement)
                    maxV = max(maxV, h)
                    sumV += s
                    growSum += currentElement.grow
                    shrinkSum += currentElement.shrink
                }
            }else{
                items.append(currentElement)
                maxV = max(maxV, h)
                sumV += s
                growSum += currentElement.grow
                shrinkSum += currentElement.shrink
            }
            index += 1
        }
        if(items.count > 0){
            lines.append(StackLine(array: items, basis: sumV, crossBasis: maxV,extraSpace: wlimit - sumV,itemGrowSum: growSum,itemShrinkSum: shrinkSum))
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
