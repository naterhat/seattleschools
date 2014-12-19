//
//  NTPanGesture.h
//  seattle_schools
//
//  Created by Nate on 12/18/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface NTPanGestureRecognizer : UIPanGestureRecognizer
@property (nonatomic) CGFloat min;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat leeway;

@end
