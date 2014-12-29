//
//  NSDictionary+ConvertValue.m
//
//  Created by Nate on 10/1/14.
//  Copyright (c) 2014 Ifcantel. All rights reserved.
//

#import "NSDictionary+ConvertValue.h"

@implementation NSDictionary (ConvertValue)

- (NSString *)stringForKey:(NSString *)key
{
    id value = [self valueForKey:key];
    if([value isKindOfClass:[NSNull class]]) return @"";
    else if([value isKindOfClass:[NSNumber class]]) return [value stringValue];
    return value;
}

- (NSNumber *)numberForKey:(NSString *)key
{
    id value = [self valueForKey:key];
    if([value isKindOfClass:[NSNull class]]) return @0;
    else if([value isKindOfClass:[NSString class]]) return @([value integerValue]);
    return value;
}

@end
