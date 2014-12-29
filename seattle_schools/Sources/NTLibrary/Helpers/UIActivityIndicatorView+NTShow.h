//
//  UIActivityIndicatorView+NTShow.h
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityIndicatorView (NTShow)

/**
 *  Show loading indicator on of everything.
 *   If called again, doesn't duplicate the indicator.
 */
+ (void)showIndicator;

/**
 *  Hide the existing loading indicator if there is one.
 */
+ (void)hideIndicator;

@end
