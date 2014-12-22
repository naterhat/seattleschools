//
//  NTFilterTransformView.m
//  seattle_schools
//
//  Created by Nate on 12/21/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTFilterTransformView.h"

@interface NTFilterTransformView ()
@property (nonatomic) NSTimeInterval lastInterval;
@property (nonatomic) NSTimeInterval deltaTime;
@end

@implementation NTFilterTransformView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [NSTimer scheduledTimerWithTimeInterval:1.0/16.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [self setBackgroundColor:[UIColor clearColor]];
    } return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
    } return self;
}

- (void)update
{
    NSTimeInterval newInterval = [[NSDate date] timeIntervalSince1970];
    self.deltaTime += newInterval - self.lastInterval;
    
//    self.meshTransform = [BCMutableMeshTransform clothMeshTransformAtPoint:CGPointZero boundsSize:CGSizeZero time:self.deltaTime];
    self.meshTransform = [self waveTransformWithTime:self.deltaTime];
    
    self.lastInterval = newInterval;
    
}

- (BCMeshTransform *)waveTransformWithTime:(NSTimeInterval)time
{
    const float Waves = 0.5;
    const float Amplitude = 0.005;
    const float DistanceShrink = 0.0;
    const int Columns = 40;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform meshTransform];
    for (int i = 0; i <= Columns; i++) {
        float t = (float) i / Columns;
        float sine = sin(t * M_PI * Waves * 1 + time);
        
        BCMeshVertex topVertex = {
            .from = {t, 0.0},
            .to = {t, Amplitude * sine * sine + DistanceShrink * t, 0.0 }
        };
        
        BCMeshVertex bottomVertex = {
            .from = {t, 1.0},
            .to = {t, 1.0 - Amplitude + Amplitude * sine * sine - DistanceShrink * t, 0.0 }
        };
        
        [transform addVertex:topVertex];
        [transform addVertex:bottomVertex];
    }
    
    for (int i = 0; i < Columns; i++) {
        uint topLeft = 2 * i + 0;
        uint topRight = 2 * i + 2;
        uint bottomRight = 2 * i + 3;
        uint bottomLeft = 2 * i + 1;
        
        [transform addFace:(BCMeshFace) {.indices = {topLeft, topRight, bottomRight, bottomLeft }}];
    }
    
    return  transform;
}

@end
