//
//  NTDetailViewController.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDetailViewController.h"
#import "NTSchool.h"

@interface NTDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@end

@implementation NTDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.school) {
        [self.addressLabel setText:self.school.address];
        [self.phoneLabel setText:self.school.phone];
        [self.websiteLabel setText:self.school.website];
    }
}


@end
