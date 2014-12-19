//
//  NTPoleView.m
//  seattle_schools
//
//  Created by Nate on 12/19/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTPoleView.h"
#import "NTTheme.h"
#import "NTMath.h"

static CGFloat const kViewMaxHeight = 2200;

@interface NTPoleView ()
@property (nonatomic) UIView *scrollView;
@property (nonatomic) UIView *middleView;
@property (nonatomic) UIView *shadeView;
@end

@implementation NTPoleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        CGSize size = self.frame.size;
        
        // create scroll view
        self.scrollView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, kViewMaxHeight)];
        UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_tile.jpg"]];
        [self.scrollView setBackgroundColor:patternColor];
        [self addSubview:self.scrollView];
        
        // create middle view
        UIView *poleMiddleView = [[UIView alloc] init];
        [poleMiddleView setBackgroundColor:[[NTTheme instance] flagBackgroundColor]];
        [self addSubview:poleMiddleView];
        _middleView = poleMiddleView;
        
        // create shade view
        UIView *shadeView = [[UIView alloc] init];
        [shadeView setBackgroundColor:[UIColor colorWithWhite:0 alpha:.15f]];
        [self addSubview:shadeView];
        _shadeView = shadeView;

    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // *** resize views
    
    // middle
    CGSize size = self.frame.size;
    CGFloat flagWidth = size.width * [[NTTheme instance] flagWidthScale];
    CGRect middleRect = CGRectMake((size.width - flagWidth) * 0.5, 0, flagWidth, size.height);
    [self.middleView setFrame:middleRect];
    
    // shade
    [self.shadeView setFrame:CGRectMake(0,
                             size.height - (size.height * .2f),
                             size.width,
                             size.height * .2f)];
}

- (void)scrollToPosition:(CGPoint)point
{
    CGRect frame = CGRectSetY(self.scrollView.frame, point.y - self.scrollView.frame.size.height/2);
    [self.scrollView setFrame:frame];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
