//
//  NTCopyrightLabel.m
//  seattle_schools
//
//  Created by Nate on 12/22/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTCopyrightLabel.h"
#import "NTTheme.h"

@implementation NTCopyrightLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        id<NTThemeProtocol> theme = [NTTheme instance];
        [self setTextColor:[theme generalTextColor]];
        [self setFont:[UIFont fontWithName:[theme generalFontName] size:11]];
    } return self;
}

@end