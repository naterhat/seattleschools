//
//  NTGroupAnnotation.h
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import "NTSchool.h"

@interface NTSchoolGroupAnnotation : NSObject<MKAnnotation>

@property (nonatomic) NSInteger groupCount;

@property (nonatomic) NTSchool *school;

@property (nonatomic) NSMutableArray *collection;

- (instancetype)initWithSchool:(NTSchool *)school;

- (UIImage *)image;

#pragma mark - For Array Controls

- (BOOL)isEmpty;

- (id)firstObject;

- (NSUInteger)count;

- (id)objectAtIndex:(NSUInteger)index;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)addObject:(id)anObject;

- (void)removeLastObject;

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (NSUInteger)indexOfObject:(id)anObject;

- (void)removeAllObjects;

@end
