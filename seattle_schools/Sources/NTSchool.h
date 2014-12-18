//
//  NTSchool.h
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

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

extern NSString *NSStringFromSchoolGrade(NTSchoolGrade grade);

//zip: "98107",
//phone: "(206) 252-1300",
//school: "Adams",
//website: "http://adamses.seattleschools.org/",
//address: "6110 28th Ave NW",
//name: "Adams",
//grade: "K - 5",
//shape: {
//needs_recoding: false,
//longitude: "-122.39151959399999",
//latitude: "47.67363214300008"
//},
//type: "Elementary",
//objectid: "1",
//city: "Seattle"

// TEST TEST TEST

@interface NTSchool : NSObject

@property (nonatomic) NSString *zip;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *grade;
@property (nonatomic) NSString *longitude;
@property (nonatomic) NSString *latitude;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *website;
@property (nonatomic) BOOL isPublic;
@property (nonatomic) UIImage *image;
@property (nonatomic) NTSchoolGrade gradeIndex;
@end

@interface NTSchool (SeattleNetwork)

- (instancetype)initWithSeattleNetworkData:(id)data;

@end
