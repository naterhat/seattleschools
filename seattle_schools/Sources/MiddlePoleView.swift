//
//  MiddlePoleView.swift
//  seattle_schools
//
//  Created by Nate on 12/21/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

import Foundation

func sidePath(rect: CGRect) -> CGPathRef {
    let path = CGPathCreateMutable()
    
    
    CGPathMoveToPoint(path, nil, rect.left, rect.top)
    CGPathAddLineToPoint(path, nil, rect.x, rect.bottom)
    CGPathMoveToPoint(path, nil, rect.right, rect.top)
    CGPathAddLineToPoint(path, nil, rect.right, rect.bottom)
    
    return path
}

class MiddlePoleView : UIView {
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let lineWidth :CGFloat = 2.0
        let lineColor = UIColor.whiteColor()
        let backgroundColor = NTTheme.instance().flagBackgroundColor()
        var flagRect = rect
        var lineRect = flagRect
        var offset : CGFloat = 3
        
        backgroundColor.setFill()
        CGContextFillRect(ctx, rect)
        
        lineRect = flagRect.resize(-offset, top: 0, right: -offset, bottom: 0)
        lineColor.setStroke()
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextAddPath(ctx, sidePath(lineRect))
        CGContextStrokePath(ctx)
        
        lineRect = flagRect.resize(-offset*2, top: 0, right: -offset*2, bottom: 0)
        lineColor.setStroke()
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextAddPath(ctx, sidePath(lineRect))
        CGContextStrokePath(ctx)
    }
}
