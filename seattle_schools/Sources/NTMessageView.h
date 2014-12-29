//
//  NTMessageView.h
//  notes
//
//  Created by Nate on 12/3/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTMessageView : UIView

/**
 *  This will create a new instance from the "NTMessageView" nib.
 *   The main reason is don't have to edit the look of the view with code.
 *   Instead, edit from nib.
 */
- (instancetype)initWithMessage:(NSString *)message center:(CGPoint)centerPoint;

- (void)setMessage:(NSString *)message;
@end
