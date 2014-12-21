//
//  BCMutableMeshTransform+DemoTransforms.h
//  BCMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "BCMeshTransform.h"

@interface BCMeshTransform (DemoTransforms)

+ (instancetype)curtainMeshTransformAtPoint:(CGPoint)point
                                 boundsSize:(CGSize)boundsSize;

+ (instancetype)clothMeshTransformAtPoint:(CGPoint)point
                               boundsSize:(CGSize)boundsSize
                                     time:(NSTimeInterval)time;

+ (instancetype)buldgeMeshTransformAtPoint:(CGPoint)point
                                withRadius:(CGFloat)radius
                                boundsSize:(CGSize)size;

+ (instancetype)shiverTransformWithPhase:(CGFloat)phase magnitude:(CGFloat)magnitude;

+ (instancetype)ellipseMeshTransform;

+ (instancetype)rippleMeshTransform;

@end
