//
//  NSDictionary+ConvertValue.h
//
//  Created by Nate on 10/1/14.
//  Copyright (c) 2014 Ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ConvertValue)

- (NSString *)stringForKey:(NSString *)key;

- (NSNumber *)numberForKey:(NSString *)key;

@end
