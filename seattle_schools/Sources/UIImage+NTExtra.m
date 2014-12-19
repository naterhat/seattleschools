//
//  UIImage+NTExtra.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "UIImage+NTExtra.h"

#define kGlobalFontName @"TrebuchetMS"

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

+ (UIImage *)imageOfNumber:(NSNumber *)number
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [NSMutableDictionary dictionary];
        
    });
    
    
    UIImage *image = [dict objectForKey:number];
    if (!image) {
        image = [UIImage imageOfASeeThroughNumber:number outerColor:kGlobalCombineColor];
        [dict setObject:image forKey:number];
    }
    
    return [image copy];
}

+ (UIImage *)imageOfASeeThroughNumber:(NSNumber *)number outerColor:(UIColor *)outerColor
{
    
    CGRect bounds = CGRectMake(0, 0, 40, 40);
    CGFloat fontSize = 20;
    NSString *fontName = @"TrebuchetMS-Bold";
    CGContextRef ctx;
    
    // ==========================================
    // Draw White Font Image
    
    UIGraphicsBeginImageContext(bounds.size);
    
    ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    // Draw black rect
    [[UIColor blackColor] setFill];
    CGContextFillRect(ctx, bounds);
    
    // Draw Font
    NSDictionary *attr = @{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize], NSForegroundColorAttributeName: [UIColor whiteColor]};
    CGSize size = [number.stringValue sizeWithAttributes:attr];
    CGRect fontBounds = CGRectMake(bounds.size.width/2 - size.width/2, bounds.size.height/2 - size.height/2, size.width, size.height);
    [number.stringValue drawInRect:fontBounds withAttributes:attr];
    
    // get image
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // ==========================================
    // Draw Circle Image
    
    UIGraphicsBeginImageContext(bounds.size);
    
    ctx = UIGraphicsGetCurrentContext();
    
    // set correct transform
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -bounds.size.height);
    
    // draw a circle
    CGRect circleBounds = CGRectInset(bounds, 5, 5);
    [outerColor setFill];
    CGContextFillEllipseInRect(ctx, circleBounds);
    
    // get image
    UIImage *cropImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // ==========================================
    // Crop Circle Image with Font Image.
    //   See through the circle with a number
    
    UIGraphicsBeginImageContext(bounds.size);
    
    ctx = UIGraphicsGetCurrentContext();
    
    // set correct transform
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -bounds.size.height);
    
    CGImageRef imgRef = [cropImage CGImage];
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);
    
    // clip the mask
    CGContextClipToMask(ctx, bounds, actualMask);
    
    // draw image around the mask
    CGContextDrawImage(ctx, bounds, imgRef);
    
    // get image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGImageRelease(actualMask);
    
    // ==========================================
    
    return newImage;
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
