//
//  NTNavigationBar.m
//  seattle_schools
//
//  Created by Nate on 12/19/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTNavigationBar.h"
#import "NTTheme.h"

@implementation NTNavigationBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setTitleTextAttributes:@{NSFontAttributeName:[[NTTheme instance] navigationTitleFont],
                                       NSForegroundColorAttributeName: [[NTTheme instance] navigationTitleColor]}];
        [self setTintColor:[[NTTheme instance] navigationTitleColor]];
        [self setBarTintColor:[[NTTheme instance] navigationBarBackgroundColor]];
        [self setTranslucent:NO];
    } return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
