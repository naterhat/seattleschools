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

@interface NTSchoolFilter : NSObject<NTFilterProvider>
@property (nonatomic) NTSchoolType type;
@property (nonatomic) NTSchoolGrade grade;
@end
