//
//  NTSchoolGrade.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NTSchool.h"

@interface NTSchoolGradeTests : XCTestCase

@end

@implementation NTSchoolGradeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    NTSchool *school = [[NTSchool alloc] init];
    
    [school setGrade:@"K-8"];
    NSLog(@"%@", NSStringFromSchoolGrade(school.gradeIndex));
    XCTAssert(school.gradeIndex & NTSchoolGradeMiddle, @"Invalid grade setter");
    
    [school setGrade:@"K-5"];
    NSLog(@"%@", NSStringFromSchoolGrade(school.gradeIndex));
    XCTAssert((school.gradeIndex & NTSchoolGradeMiddle) == false, @"Invalid grade setter");
    
    [school setGrade:@"K-5"];
    NSLog(@"%@", NSStringFromSchoolGrade(school.gradeIndex));
    XCTAssert((school.gradeIndex & NTSchoolGradeHigh) == false, @"Invalid setter");
    
    [school setGrade:@"P-12"];
    NSLog(@"%@", NSStringFromSchoolGrade(school.gradeIndex));
    XCTAssert((school.gradeIndex & NTSchoolGradeHigh), @"Invalid setter");
    
    [school setGrade:@"9-12"];
    NSLog(@"%@", NSStringFromSchoolGrade(school.gradeIndex));
    XCTAssert((school.gradeIndex & NTSchoolGradeElementary) == false, @"Invalid setter");
    
    [school setGrade:@"9-12"];
    NSLog(@"%@", NSStringFromSchoolGrade(school.gradeIndex));
    XCTAssert((school.gradeIndex & NTSchoolGradeMiddle) == false, @"Invalid setter");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
