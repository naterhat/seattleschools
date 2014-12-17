//
//  NTSchoolFilter.h
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTFilterProvider.h"
#import "NTSchool.h"

typedef NS_ENUM(NSUInteger, NTSchoolType) {
    NTSchoolTypeAll,
    NTSchoolTypePrivate,
    NTSchoolTypePublic,
};

typedef NS_ENUM(NSUInteger, NTSchoolGrade) {
    NTSchoolGradeAll = 0,
    NTSchoolGradeElementary = 1 << 1,
    NTSchoolGradeMiddle = 1 << 2,
    NTSchoolGradeHigh = 1 << 3,
};

@interface NTSchoolFilter : NSObject<NTFilterProvider>
@property (nonatomic) NTSchoolType type;
@property (nonatomic) NTSchoolGrade grade;
@end
