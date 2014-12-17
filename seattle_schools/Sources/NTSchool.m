//
//  NTSchool.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTSchool.h"

@implementation NTSchool

- (NSString *)description
{
    return [NSString stringWithFormat:@"isPublic: %@", self.isPublic ? @"YES": @"NO"];
}

@end


@implementation NTSchool (SeattleNetwork)

- (instancetype)initWithSeattleNetworkData:(id)data
{
    if(self = [super init]) {
        _zip = data[@"zip"];
        _phone = data[@"phone"];
        _name = data[@"name"];
        _grade = data[@"grade"];
        _longitude = data[@"shape"][@"longitude"];
        _latitude = data[@"shape"][@"latitude"];
        _type = data[@"type"];
        _website = data[@"website"];
        _isPublic = YES;
        if(!_type) {
            _isPublic = NO;
        }
    } return self;
}



@end
