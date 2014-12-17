//
//  NTSchoolAnnotate.m
//  seattle_schools
//
//  Created by Nate on 12/15/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTSchoolAnnotate.h"


@implementation NTSchoolAnnotate

- (instancetype)initWithSchool:(NTSchool *)school
{
    if (self = [super init]) {
        _school = school;
    } return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(_school.latitude.doubleValue, _school.longitude.doubleValue);
}

- (NSString *)title
{
    return _school.name;
}

- (NSString *)subtitle
{
    return _school.grade;
}


@end
