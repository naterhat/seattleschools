//
//  NTTheme.h
//  seattle_schools
//
//  Created by Nate on 12/19/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NTThemeProtocol <NSObject>

- (UIColor *)navigationTitleColor;
- (UIColor *)navigationBarBackgroundColor;
- (UIFont *)navigationTitleFont;

- (UIColor *)flagBackgroundColor;
- (UIColor *)flagTextColors;
- (CGFloat)flagWidthScale;
- (UIColor *)flagSelectedColor;
- (UIColor *)flagShadowColor;

- (UIColor *)detailViewBackgroundColor;
- (UIColor *)detailViewTextColor;

- (UIColor *)generalTextColor;
- (UIFont *)generalFont;




@end

@interface NTTheme1 : NSObject <NTThemeProtocol>
@end

@interface NTTheme : NSObject
+ (id<NTThemeProtocol>)instance;
@end






