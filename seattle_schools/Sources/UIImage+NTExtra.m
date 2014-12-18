//
//  UIImage+NTExtra.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "UIImage+NTExtra.h"

#define kGlobalPublicColor [UIColor colorWithRed:0.310f green:0.627f blue:0.757f alpha:1.0f]
#define kGlobalPrivateColor [UIColor colorWithRed:0.769f green:0.267f blue:0.400f alpha:1.0f]
#define kGlobalCombineColor [UIColor colorWithRed:0.439f green:0.384f blue:0.529f alpha:1.0f]

@implementation UIImage (NTExtra)

+ (UIImage *)imageOfPublicSchool
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsEndImageContext();
        image = [UIImage imageNamed:@"school7"];
        image = [self fillImage:image withColor:kGlobalPublicColor];
    });
    
    return [image copy];
}

+ (UIImage *)imageOfPrivateSchool
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"school47"];
        image = [self fillImage:image withColor:kGlobalPrivateColor];
    });
    
    return [image copy];
}

+ (UIImage *)imageOfCombineSchool
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"school37"];
        image = [self fillImage:image withColor:kGlobalCombineColor];
    });
    
    return [image copy];
}

+ (UIImage *)fillImage:(UIImage *)image withColor:(UIColor *)fillColor
{
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // set correct transform
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -image.size.height);
    
    // save
    CGContextSaveGState(ctx);
    
    // clip
    CGContextClipToMask(ctx, bounds, image.CGImage);
    
    // set color
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    
    // draw inside clip
    CGContextFillRect(ctx, bounds);
    
    // end clip by restore
    CGContextRestoreGState(ctx);
    
    // last . . . get image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
