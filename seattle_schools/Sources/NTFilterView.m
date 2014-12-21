//
//  NTFilterView.m
//  seattle_schools
//
//  Created by Nate on 12/19/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTFilterView.h"
#import "NTTheme.h"

@implementation NTFilterView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
//        [self setBackgroundColor:[[NTTheme instance] flagBackgroundColor]];
    } return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[[NTTheme instance] flagBackgroundColor] setFill];
    CGContextFillRect(ctx, rect);
    
    NSLog(@"Filter DrawRect:");
}


@end
