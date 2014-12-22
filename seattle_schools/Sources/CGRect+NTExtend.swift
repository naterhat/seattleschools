//
//  CGRect+NTExtend.swift
//  seattle_schools
//
//  Created by Nate on 12/21/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

import Foundation

extension CGRect {
    var x : CGFloat { return origin.x }
    var y : CGFloat { return origin.y }
    var bottom : CGFloat { return height + y }
    var center : CGPoint { return CGPoint(x: x+width*0.5, y: y+height*0.5) }
    var right : CGFloat { return x + width }
    var top : CGFloat { return y }
    var left : CGFloat { return x }
    
    func resize(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) -> CGRect {
        return CGRect(
            x: self.x-left,
            y: self.y-top,
            width: self.width+right+left,
            height: self.height+bottom+top)
    }
    
    func scale(scale: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        return self.scale(scale, scaleY: scale, anchor: anchor)
    }
    
    func scale(scaleX: CGFloat, scaleY: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let newWidth = self.width * scaleX
        let newHeight = self.height * scaleY
        let x = self.x + (self.width * anchor.x) - (newWidth * anchor.x)
        let y = self.y + (self.height * anchor.y) - (newHeight * anchor.y)
        return CGRect(
            x: x,
            y: y,
            width: newWidth,
            height: newHeight)
    }
}
