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
    
    if (_grade != NTSchoolGradeAll) {
        NSPredicate *gradePred = nil;
        if(_grade & NTSchoolGradeElementary) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"grade = %@", @"elementary"];
            if (gradePred) gradePred = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred, gradePred]];
            else gradePred = pred;
        }
        
        if(_grade & NTSchoolGradeMiddle) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"grade = %@", @"middle"];
            if (gradePred) gradePred = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred, gradePred]];
            else gradePred = pred;
        }
        
        if(_grade & NTSchoolGradeHigh) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"grade = %@", @"high"];
            if (gradePred) gradePred = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred, gradePred]];
            else gradePred = pred;
        }
        
        if (compoundPredicate && gradePred) {
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[compoundPredicate, gradePred]];
        } else {
            compoundPredicate = gradePred;
        }
    }
    
    return compoundPredicate;
}


@end
