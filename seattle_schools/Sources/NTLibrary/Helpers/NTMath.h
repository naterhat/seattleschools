//
//  NTMath.h
//  seattle_schools
//
//  Created by Nate on 12/15/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_INLINE CGPoint CGPointDifference(CGPoint from, CGPoint to) {
    return CGPointMake(to.x - from.x, to.y - from.y);
}

NS_INLINE CGPoint CGPointAdd(CGPoint pointA, CGPoint pointB) {
    return CGPointMake(pointA.x + pointB.x, pointA.y + pointB.y);
}

NS_INLINE CGRect CGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = y;
    return rect;
}

NS_INLINE CGRect CGRectSetX(CGRect rect, CGFloat x) {
    rect.origin.x = x;
    return rect;
}

NS_INLINE CGRect CGRectSetOrigin(CGRect rect, CGPoint origin) {
    rect.origin = origin;
    return rect;
}

NS_INLINE CGRect CGRectMove(CGRect rect, CGPoint move) {
    rect.origin = CGPointAdd(rect.origin, move);
    return rect;
}

NS_INLINE CGFloat CGPointMagnitude(CGPoint point)
{
    return sqrt(point.x * point.x + point.y * point.y);
}

NS_INLINE CGPoint CGPointNormalize(CGPoint point) {
    CGFloat m = CGPointMagnitude(point);
    return CGPointMake(m / point.x, m / point.y);
}



