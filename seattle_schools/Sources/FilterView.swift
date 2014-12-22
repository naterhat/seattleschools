//
//  FilterView.swift
//  seattle_schools
//
//  Created by Nate on 12/21/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

import Foundation
import UIKit

func flagPath(rect: CGRect, bottomHeight: CGFloat, closed: Bool) -> CGPathRef {
    let path = CGPathCreateMutable()
    
    
    CGPathMoveToPoint(path, nil, rect.x, rect.y)
    CGPathAddLineToPoint(path, nil, rect.x, rect.bottom-bottomHeight)
    CGPathAddLineToPoint(path, nil, rect.center.x, rect.bottom)
    CGPathAddLineToPoint(path, nil, rect.right, rect.bottom-bottomHeight)
    CGPathAddLineToPoint(path, nil, rect.right, rect.top)
    
    if closed {
        CGPathCloseSubpath(path)
    }
    
    
    return path
}

class FilterView: UIView {
    
    override func awakeFromNib() {
        backgroundColor = UIColor.clearColor()
        
        layer.shadowColor = NTTheme.instance().flagShadowColor().CGColor
        layer.shadowRadius = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 2)
        
    }

    override func drawRect(rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        let bottomHeight : CGFloat = 40
        let lineWidth :CGFloat = 2.0
        let lineColor = UIColor.whiteColor()
        let backgroundColor = NTTheme.instance().flagBackgroundColor()
        let shadowColor = NTTheme.instance().flagShadowColor()
        let shadowRadius : CGFloat = 5.0
        let shadowOffset = CGSize(width: 1, height: 0)
        var flagRect = CGRect(x: 10, y: 0, width: rect.width-20, height: rect.height-10)
        var lineRect = flagRect
        var offset : CGFloat = 3
        var ratio : CGFloat = 0
        
        backgroundColor.setFill()
        CGContextAddPath(ctx, flagPath(flagRect, bottomHeight, true))
        CGContextSetShadowWithColor(ctx, shadowOffset, shadowRadius, shadowColor.CGColor)
        CGContextFillPath(ctx)
        
        lineRect = flagRect.resize(-offset, top: 0, right: -offset, bottom: -offset)
        ratio = lineRect.height/flagRect.height
        lineColor.setStroke()
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextAddPath(ctx, flagPath(lineRect, bottomHeight * ratio * ratio, false))
        CGContextStrokePath(ctx)
        
        lineRect = flagRect.resize(-offset*2, top: 0, right: -offset*2, bottom: -offset*2)
        ratio = lineRect.height/flagRect.height
        lineColor.setStroke()
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextAddPath(ctx, flagPath(lineRect, bottomHeight * ratio * ratio, false))
        CGContextStrokePath(ctx)
    
    }
}