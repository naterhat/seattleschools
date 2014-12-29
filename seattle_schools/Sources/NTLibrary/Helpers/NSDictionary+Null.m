//
//  NSDictionary+Null.m
//
//  Created by Nate on 10/1/14.
//  Copyright (c) 2014 Ifcantel. All rights reserved.
//

#import "NSDictionary+Null.h"

@implementation NSDictionary (Null)

- (NSDictionary *)dictionaryByRemovingNull
{
    NSDictionary *editDict = [self removeNullFromObject:self];
    return editDict;
}

- (id)removeNullFromObject:(id)obj
{
    
    // check key object for null
    if([obj isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *dict = [obj mutableCopy];
        for (NSString *key in dict.allKeys) {
            dict[key] = [self removeNullFromObject:dict[key]];
        }
        return dict;
    }
    
    // check the array of null objects
    else if([obj isKindOfClass:[NSArray class]]){
        NSMutableArray *array = [obj mutableCopy];
        for (int i = (int)array.count-1; i < array.count; i--) {
            array[i] = [self removeNullFromObject:array[i]];
        }
        return array;
    }
    
    // if null - set to empty string
    else if([obj isKindOfClass:[NSNull class]]){
        return @"";
    }
    
    return obj;
}
                
                

@end
