//
//  NTTheme.m
//  seattle_schools
//
//  Created by Nate on 12/19/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTTheme.h"

@implementation NTTheme

+ (id<NTThemeProtocol>)instance
{
    static id<NTThemeProtocol> instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTTheme1 alloc] init];
    });
    return instance;
}

@end

@implementation NTTheme1

// Navigation
- (UIColor *)navigationTitleColor {
    return [UIColor colorWithRed:0.965f green:0.953f blue:0.925f alpha:1.0f];
}

- (UIColor *)navigationBarBackgroundColor {
    return [UIColor colorWithRed:0.808f green:0.459f blue:0.345f alpha:1.0f];
}

- (UIFont *)navigationTitleFont {
    return [UIFont fontWithName:@"Caviar Dreams" size:20];
}


// Flag
- (UIColor *)flagBackgroundColor {
    return [UIColor colorWithRed:0.216f green:0.498f blue:0.600f alpha:1.0f];
}
- (UIColor *)flagTextColors {
    return [UIColor colorWithRed:0.965f green:0.953f blue:0.925f alpha:1.0f];
}

- (CGFloat)flagWidthScale
{
    return 0.9f;
}

- (UIColor *)flagSelectedColor {
    return [UIColor colorWithRed:0.243f green:0.557f blue:0.671f alpha:1.0f];
}

- (UIColor *)flagShadowColor {
    return [UIColor colorWithRed:0.137f green:0.318f blue:0.384f alpha:1.0f];
}


// Detail
- (UIColor *)detailViewBackgroundColor {
    return [UIColor colorWithRed:0.965f green:0.953f blue:0.925f alpha:1.0f];
}

- (UIColor *)detailViewTextColor {
    return [UIColor colorWithRed:0.216f green:0.498f blue:0.600f alpha:1.0f];
}


// General
- (UIColor *)generalTextColor {
    return [UIColor colorWithRed:0.965f green:0.953f blue:0.925f alpha:1.0f];
}

- (UIFont *)generalFont {
    return [UIFont fontWithName:[self generalFontName] size:15];
}

- (NSString *)generalFontName {
    return @"Caviar Dreams";
}



@end


