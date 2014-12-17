//
//  NTFilterViewController.h
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTSchoolFilter.h"

@protocol NTFilterViewControllerDelegate;

@interface NTFilterViewController : UIViewController
@property (nonatomic) NSPredicate *predicate;
@property (nonatomic, weak) id<NTFilterViewControllerDelegate> delegate;
@end

@protocol NTFilterViewControllerDelegate <NSObject>
- (void)filterViewControllerDidChangePredicate:(id<NTFilterProvider>)filter;
@end
