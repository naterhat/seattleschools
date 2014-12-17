//
//  NTJSONLocalCollector+NTSeattle.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTJSONLocalCollector+NTSeattle.h"
#import "NTSchool.h"
#import "NSDictionary+Null.h"

static NSString *const kURLPrivate = @"private_schools.json";
static NSString *const kURLPublic = @"public_schools.json";

@implementation NTJSONLocalCollector (NTSeattle)

- (void)retrieveSchoolsWithHandler:(NTNetworkRetrieveCollection)handler
{
    __weak typeof (self) weakself = self;
    __block NSMutableArray *schools = [NSMutableArray array];
    [self retrieveSchoolsWithHandler:^(NSArray *items, NSError *error) {
        if(items) {
            [schools addObjectsFromArray:items];
        }
        [weakself retrieveSchoolsWithHandler:^(NSArray *items, NSError *error) {
            if(items) {
                [schools addObjectsFromArray:items];
            }
            handler(schools, error);
        } isPublic:NO];
    } isPublic:YES];
}

- (void)retrieveSchoolsWithHandler:(NTNetworkRetrieveCollection)handler isPublic:(BOOL)isPublic
{
    NSString *fileName;
    if(isPublic) fileName = kURLPublic;
    else fileName = kURLPrivate;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
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
