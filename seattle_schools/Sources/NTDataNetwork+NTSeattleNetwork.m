//
//  NTDataNetwork+NTSeattleNetwork.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDataNetwork+NTSeattleNetwork.h"
#import "NTSchool.h"
#import "NSDictionary+Null.h"

// Private: https://data.seattle.gov/resource/gza6-uqxz.json
// Public:  https://data.seattle.gov/resource/ywms-iep2.json

static NSString *const kURLDomain = @"data.seattle.gov";
static NSString *const kURLPath = @"/resource";
static NSString *const kURLPrivate = @"/gza6-uqxz.json";
static NSString *const kURLPublic = @"/ywms-iep2.json";

@interface NTDataNetwork ()
@property (nonatomic) BOOL downloading;
@property (nonatomic) NSInteger queueCount;
@end

@implementation NTDataNetwork (NTSeattleNetwork)

- (void)retrieveSchoolsWithHandler:(NTNetworkRetrieveCollection)handler
{
    __block NSMutableArray *schools = [NSMutableArray array];
    [self retrieveSchoolsWithHandler:^(NSArray *items, NSError *error) {
        if(items) {
            [schools addObjectsFromArray:items];
        }
        [self retrieveSchoolsWithHandler:^(NSArray *items, NSError *error) {
            if(items) {
                [schools addObjectsFromArray:items];
            }
            handler(schools, error);
        } isPublic:NO];
    } isPublic:YES];
    
//    NSString *path = [NSString stringWithFormat:@"https://%@%@%@", kURLDomain, kURLPath, kURLPublic];
//    [self retrieveCollectionWithHandler:^(NSArray *items, NSError *error) {
//        
//        // create each passed school from server into native object.
//        NSMutableArray *schools = [NSMutableArray array];
//        for (NSDictionary *dItem in items) {
//            NSDictionary *removedNullDictionary = dItem.dictionaryByRemovingNull;
//            NTSchool *school = [[NTSchool alloc] initWithSeattleNetworkData:removedNullDictionary];
//            [schools addObject:school];
//        }
//        handler(schools, nil);
//    } atPath:path];
}

- (void)retrieveSchoolsWithHandler:(NTNetworkRetrieveCollection)handler isPublic:(BOOL)isPublic
{
    NSString *endPath;
    if(isPublic) endPath = kURLPublic;
    else endPath = kURLPrivate;
    
    NSString *path = [NSString stringWithFormat:@"https://%@%@%@", kURLDomain, kURLPath, endPath];
    [self retrieveCollectionWithHandler:^(NSArray *items, NSError *error) {
        
        // create each passed school from server into native object.
        NSMutableArray *schools = [NSMutableArray array];
        for (NSDictionary *dItem in items) {
            NSDictionary *removedNullDictionary = dItem.dictionaryByRemovingNull;
            NTSchool *school = [[NTSchool alloc] initWithSeattleNetworkData:removedNullDictionary];
            [schools addObject:school];
        }
        handler(schools, nil);
    } atPath:path];
}

@end
