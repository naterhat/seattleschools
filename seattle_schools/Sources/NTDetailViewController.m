//
//  NTDetailViewController.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDetailViewController.h"
#import <MapKit/MapKit.h>
#import "NTSchool.h"
#import "NTTheme.h"


static NSInteger const kTagAlertDirection = 1;
static NSInteger const kTagAlertPhone = 2;
static NSInteger const kTagAlertWeb = 3;

@interface NTDetailViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *gradeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *webButton;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@end

@implementation NTDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set background color
    [self.view setBackgroundColor:[[NTTheme instance] detailViewBackgroundColor]];
    
    // set image view to aspect fit
    [ @[self.addressButton, self.webButton, self.phoneButton] setValue:@(UIViewContentModeScaleAspectFit) forKeyPath:@"imageView.contentMode"];
    
    // set label info from school object
    if(self.school) {
        
        // set title
        self.title = [self.school.name capitalizedString];
        
        [self.gradeLabel setText:self.school.grade];
        [self.addressLabel setText:self.school.address];
        [self.phoneLabel setText:self.school.phone];
        [self.websiteLabel setText:self.school.website];
        if(self.school.image) {
            [self.imageView setImage:self.school.image];
        } else {
            [self.imageView setImage:[UIImage imageNamed:@"school50"]];
        }
        
        // validate phone
        if (!self.school.phone) {
            [self.phoneButton setEnabled:NO];
        }
        
        // validate web
        if (!self.school.website) {
            [self.webButton setEnabled:NO];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.addressButton setAlpha:0];
    [self.phoneButton setAlpha:0];
    [self.webButton setAlpha:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGAffineTransform scale = CGAffineTransformMakeScale(.3f, .3f);
    
    // scale down
    [ @[self.addressButton, self.webButton, self.phoneButton]
     setValue:[NSValue valueWithCGAffineTransform:scale]
     forKeyPath:@"transform"];
    
    // scale and show the buttons with animation
    [UIView animateWithDuration:1.0f delay:0 usingSpringWithDamping:.3f initialSpringVelocity:0 options:0 animations:^{
        [self.addressButton setAlpha:1];
        [self.phoneButton setAlpha:1];
        [self.webButton setAlpha:1];
        
        // reset to original size
        [ @[self.addressButton, self.webButton, self.phoneButton]
         setValue:[NSValue valueWithCGAffineTransform:CGAffineTransformIdentity]
         forKeyPath:@"transform"];
    } completion:nil];
    
}

#pragma mark - Actions

- (IBAction)selectAddress:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Map Direction" message:@"Would you like direction to the school?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Direction", nil];
    [alert show];
    [alert setTag:kTagAlertDirection];
}

- (IBAction)selectPhone:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call" message:@"Would you like to call the school?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
    [alert show];
    [alert setTag:kTagAlertPhone];
}

- (IBAction)selectWeb:(id)sender {
    NSString *urlPath = [NSString stringWithFormat:@"http://%@", self.school.website];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kTagAlertDirection) {
        if (buttonIndex == 0) {
            // cancel
        } else {
            // open Apple Maps to give direction
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.school.latitude.doubleValue, self.school.longitude.doubleValue);
            MKPlacemark *mark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
            MKMapItem *direction = [[MKMapItem alloc] initWithPlacemark:mark];
            [direction openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        }
    } else if (alertView.tag == kTagAlertPhone) {
        if (buttonIndex == 0) {
           // cancel
        } else {
            // trim phone number to only decimals
            NSMutableCharacterSet *set = [NSMutableCharacterSet punctuationCharacterSet];
            [set addCharactersInString:@" "];
            NSString *phone = [[self.school.phone componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
            
            NSString *scheme = [NSString stringWithFormat:@"tel:%@", phone ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
        }
    } else if (alertView.tag == kTagAlertWeb) {
        
    }
}

@end
