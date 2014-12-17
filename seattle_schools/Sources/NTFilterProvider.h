//
//  NTSchoolFilter.h
//  seattle_schools
//
//  Created by Nate on 12/16/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTFilterProvider <NSObject>
@property (nonatomic) NSPredicate *predicate;
@end
