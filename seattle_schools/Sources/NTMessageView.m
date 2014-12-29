//
//  NTMessageView.m
//  notes
//
//  Created by Nate on 12/3/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTMessageView.h"

@interface NTMessageView ()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end

@implementation NTMessageView

- (instancetype)initWithMessage:(NSString *)message center:(CGPoint)centerPoint
{
    self = (id)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    if( self ) {
        [self.messageLabel setText:message];
        
        // size and position
        [self setFrame:CGRectMake(0, 0, 150, 150)];
        [self setCenter:centerPoint];
        
        // radius
        [self.layer setCornerRadius:8];
        [self.layer setMasksToBounds:YES];
    } return self;
}

- (void)setMessage:(NSString *)message
{
    [self.messageLabel setText:message];
}



@end
