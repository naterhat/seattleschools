//
//  NTSchoolFilter.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTSchoolFilter.h"

@interface NTSchoolFilter ()
@end

@implementation NTSchoolFilter
@synthesize predicate = _predicate;

- (void)setType:(NTSchoolType)type
{
    _type = type;
}

- (void)setGrade:(NTSchoolGrade)grade
{
    _grade = grade;
}

- (NSPredicate *)predicate
{
    // create predicate for school type: PUBLIC OR PRIVATE.
    //   If none is set, then both are selected. No need to create predicate.
    NSPredicate *compoundPredicate = nil;
    switch (_type) {
        case NTSchoolTypeAll:
            break;
        case NTSchoolTypePrivate:
            compoundPredicate = [NSPredicate predicateWithFormat:@"isPublic = %@", @(NO)];
            break;
        case NTSchoolTypePublic:
            compoundPredicate = [NSPredicate predicateWithFormat:@"isPublic = %@", @(YES)];
            break;
            
        default:
            break;
    }
    
    // Create a filter for school grade level.
    if (_grade != NTSchoolGradeAll) {
        NSPredicate *gradePred = nil;
        if(_grade & NTSchoolGradeElementary) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(gradeIndex & %d) == %d", NTSchoolGradeElementary, NTSchoolGradeElementary];
            if (gradePred) gradePred = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred, gradePred]];
            else gradePred = pred;
        }
        
        if(_grade & NTSchoolGradeMiddle) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(gradeIndex & %d) == %d", NTSchoolGradeMiddle, NTSchoolGradeMiddle];
            if (gradePred) gradePred = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred, gradePred]];
            else gradePred = pred;
        }
        
        if(_grade & NTSchoolGradeHigh) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(gradeIndex & %d) == %d", NTSchoolGradeHigh, NTSchoolGradeHigh];
            if (gradePred) gradePred = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred, gradePred]];
            else gradePred = pred;
        }
        
        // compound school type and school grade for filtering.
        if (compoundPredicate && gradePred) {
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[compoundPredicate, gradePred]];
        } else {
            compoundPredicate = gradePred;
        }
    }
    
    return compoundPredicate;
}


@end
