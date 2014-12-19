//
//  NTGroupAnnotation.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTSchoolGroupAnnotation.h"
#import "UIImage+NTExtra.h"

@implementation NTSchoolGroupAnnotation
@synthesize coordinate = _coordinate;

- (instancetype)initWithSchool:(NTSchool *)school
{
    if(self = [self init]){
        [self addObject:school];
    } return self;
}

- (instancetype)init
{
    if(self = [super init]) {
        _collection = [NSMutableArray array];
    } return self;
}

- (UIImage *)image
{
    // if count more than 1, show number annotation.
    //  Otherwise, display public or private image
    //   depends on the first school object from collection.
    if (self.count > 1) {
        return [UIImage imageOfNumber:@(self.count)];
    } else {
        if ([self.firstObject isPublic])
            return [UIImage imageOfPublicSchool];
        else
            return [UIImage imageOfPrivateSchool];
    }
    
    return nil;
}

#pragma mark - MKAnnotation Protocol

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (NSString *)subtitle
{
    if(!self.isEmpty)
        return [self.collection.firstObject grade];
    return @"";
}

- (NSString *)title
{
    if(!self.isEmpty)
        return [self.collection.firstObject name];
    return @"";
}

#pragma mark - Array Methods

- (BOOL)isEmpty
{
    return self.collection.count == 0;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    
}

#pragma mark -
#pragma mark - Override Methods

- (id)firstObject
{
    return self.collection.firstObject;
}

- (NSUInteger)count
{
    return self.collection.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.collection objectAtIndex:index];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    return [self.collection insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    return [self.collection removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject
{
    [self.collection addObject:anObject];
    
    // set coordinate
    if(self.count == 1) {
        NTSchool *school = self.collection.firstObject;
        _coordinate = CLLocationCoordinate2DMake(school.latitude.doubleValue, school.longitude.doubleValue);
    }
}

- (void)removeLastObject
{
    [self.collection removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self.collection replaceObjectAtIndex:index withObject:anObject];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    return [self.collection indexOfObject:anObject];
}

- (void)removeAllObjects
{
    [self.collection removeAllObjects];
}

@end
