//
//  NTDetailViewController.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDetailViewController.h"
#import "NTSchool.h"
#import <MapKit/MapKit.h>

static NSInteger const kTagAlertDirection = 1;
static NSInteger const kTagAlertPhone = 2;
static NSInteger const kTagAlertWeb = 3;


@interface NTDetailViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *webButton;
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
    NSURL *url = [NSURL URLWithString:self.school.website];
    [[UIApplication sharedApplication] openURL:url];
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
