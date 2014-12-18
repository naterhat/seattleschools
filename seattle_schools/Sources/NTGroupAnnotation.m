//
//  NTGroupAnnotation.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTGroupAnnotation.h"

@implementation NTGroupAnnotation

- (instancetype)init
{
    if(self = [super init]) {
        _collection = [NSMutableArray array];
    } return self;
}

- (CLLocationCoordinate2D)coordinate
{
    if(_collection.count) {
        id<MKAnnotation> annotation = _collection.firstObject;
        return [annotation coordinate];
    } else {
        return CLLocationCoordinate2DMake(0, 0);
    }
}

- (NSString *)subtitle
{
    return @"";
}

- (NSString *)title
{
    return @"";
}

@end
