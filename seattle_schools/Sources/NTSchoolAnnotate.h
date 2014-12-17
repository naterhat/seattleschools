//
//  NTSchoolAnnotate.h
//  seattle_schools
//
//  Created by Nate on 12/15/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "NTSchool.h"

@interface NTSchoolAnnotate : NSObject<MKAnnotation>
@property (nonatomic, readonly) NTSchool *school;
- (instancetype)initWithSchool:(NTSchool *)school;
@end
