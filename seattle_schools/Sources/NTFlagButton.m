//
//  NTFlagButton.m
//  seattle_schools
//
//  Created by Nate on 12/19/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTFlagButton.h"
#import "NTTheme.h"

@implementation NTFlagButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // set title color - selected / unselected
        [self setTitleColor:[[NTTheme instance] flagTextColors] forState:UIControlStateNormal];
        [self setTitleColor:[[NTTheme instance] flagTextColors] forState:UIControlStateSelected];
        
        // set button appearance
        [self.layer setShadowColor:[[NTTheme instance] flagShadowColor].CGColor];
        [self.layer setShadowRadius:0.5f];
        [self.layer setShadowOffset:CGSizeMake(2, 2)];
        [self.layer setBorderWidth:1];
        [self.layer setBorderColor:[UIColor clearColor].CGColor];
        
        // set the appearance of the title label
        [self.titleLabel setFont:[[NTTheme instance] generalFont]];
        [self.titleLabel setMinimumScaleFactor:.5f];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
    } return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        [self setBackgroundColor:[[NTTheme instance] flagSelectedColor]];
        self.layer.shadowOpacity = 1.0;
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
        self.layer.shadowOpacity = 0.0;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
