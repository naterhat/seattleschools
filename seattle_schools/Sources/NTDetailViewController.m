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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation NTDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    if(self.school) {
        self.title = [self.school.name capitalizedString];
        
        [self.addressLabel setText:self.school.address];
        [self.phoneLabel setText:self.school.phone];
        [self.websiteLabel setText:self.school.website];
        if(self.school.image) {
            [self.imageView setImage:self.school.image];
        } else {
            [self.imageView setImage:[UIImage imageNamed:@"school50"]];
        }
    }
}


@end
