//
//  NTFilterContainer.m
//  seattle_schools
//
//  Created by Nate on 12/22/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTFilterContainer.h"


@implementation NTFilterContainer

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        
        // loop through each subview
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            // if hit subview, then return subview
            if (hitTestView) {
                return hitTestView;
            }
        }
        return nil;
    }
    return nil;
}

@end
