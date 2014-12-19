//
//  NTLabel.m
//  seattle_schools
//
//  Created by Nate on 12/19/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDetailLabel.h"
#import "NTTheme.h"

@implementation NTDetailLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setTextColor:[[NTTheme instance] detailViewTextColor]];
        [self setFont:[[NTTheme instance] generalFont]];
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
