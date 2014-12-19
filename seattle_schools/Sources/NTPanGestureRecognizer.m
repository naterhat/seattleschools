//
//  NTPanGesture.m
//  seattle_schools
//
//  Created by Nate on 12/18/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTPanGestureRecognizer.h"
#import "NTMath.h"

@interface NTPanGestureRecognizer ()
{
    CGPoint _startPosition;
    CGFloat _speed;
    NSTimeInterval _time;
}
@property (nonatomic) NSTimer *timer;
@end

@implementation NTPanGestureRecognizer

- (instancetype)init
{
    if (self = [super init]) {
        _speed = 0;
        _time = 0.3;
    } return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!self.view) return;
    
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    _startPosition = self.view.frame.origin;
    
    NSLog(@"begin");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.view) return;
    
    CGPoint translate = [self translationInView:self.view];
    CGPoint position = _startPosition;
    position.y += translate.y;
    CGRect frame = CGRectSetOrigin(self.view.frame, position);
    
    // restrict view controller movement
    if( frame.origin.y > self.max + self.leeway) {
        frame.origin.y = self.max + self.leeway;
    }
    self.view.frame = frame;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (!self.view) return;

    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    
    // calculate speed
    CGFloat distance = self.restPosition.y - self.view.frame.origin.y;
    _speed = distance / _time;
    
    NSLog(@"end");
}

- (CGPoint)restPosition
{
    CGFloat mid = (self.min + self.max) / 2.0f;
    
    // bound frame
    CGRect frame = self.view.frame;
    if ( frame.origin.y < mid ) {
        frame.origin.y = _min;
    } else {
        frame.origin.y = _max;
    }
    
    return frame.origin;
}

- (void)update
{
    CGFloat offset = .5f;
    
    
    
    
//    [self.view setFrame:frame];
//    
//    // retrieve position
//    CGPoint position;
//    position.x =  frame.origin.x + frame.size.width/2;
//    position.y =  frame.origin.y + frame.size.height/2;
}

@end
