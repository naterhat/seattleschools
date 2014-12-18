//
//  NTSchool.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTSchool.h"

NSString *NSStringFromSchoolGrade(NTSchoolGrade grade)
{
    NSMutableString *str = [NSMutableString string];
    
    if( grade & NTSchoolGradeElementary ) [str appendString:@"Elementary,"];
    if( grade & NTSchoolGradeMiddle ) [str appendString:@"Middle,"];
    if( grade & NTSchoolGradeHigh ) [str appendString:@"High,"];
    
    return str;
}

@implementation NTSchool

- (NSString *)description
{
    return [NSString stringWithFormat:@"isPublic: %@", self.isPublic ? @"YES": @"NO"];
}

- (void)setGrade:(NSString *)grade
{
    _grade = grade;
    
    if (_grade) {
        NSInteger min = 0;
        NSInteger max = 0;
        // break apart the components
        NSArray *comps = [_grade componentsSeparatedByString:@"-"];
        if(comps.count > 1){
            min = [comps[0] integerValue];
            max = [comps[1] integerValue];
        } else {
            min = [comps[0] integerValue];
            max = min;
        }
        
        // E: 0 - 6
        // M: 7 - 8
        // H: 9 - 12
        
        // 0 - 5
        // 9 - 12
        // 0 - 8
        // 0 - 12
        
        // check elementary
        _gradeIndex = 0;
        if(min < 7) {
            _gradeIndex = _gradeIndex | NTSchoolGradeElementary;
        }
        
        if(min < 9 && max > 6) {
            _gradeIndex = _gradeIndex | NTSchoolGradeMiddle;
        }
        
        if(max > 8) {
            _gradeIndex = _gradeIndex | NTSchoolGradeHigh;
        }
    }
}

@end


@implementation NTSchool (SeattleNetwork)

- (instancetype)initWithSeattleNetworkData:(id)data
{
    if(self = [super init]) {
        _zip = data[@"zip"];
        _phone = data[@"phone"];
        _name = data[@"name"];
        _longitude = data[@"shape"][@"longitude"];
        _latitude = data[@"shape"][@"latitude"];
        _type = data[@"type"];
        
        _website = data[@"website"];
        if (_website) {
            _website = [_website stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            _website = [_website stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        }
        
        _isPublic = YES;
        if(!_type) {
            _isPublic = NO;
        }
        
        [self setGrade:data[@"grade"]];
    } return self;
}



@end
