//
//  NTLocationManager.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTLocationManager.h"

@interface NTLocationManager ()<CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation NTLocationManager

+ (instancetype)sharedInstance
{
    static NTLocationManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NTLocationManager alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    if(self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self setupCoreLocation];
    } return self;
}

- (MKCoordinateRegion)regionByCurrentLocation
{
    CLLocationCoordinate2D coord = self.locationManager.location.coordinate;
    MKCoordinateRegion region =  MKCoordinateRegionMake(coord, MKCoordinateSpanMake(5, 5));
    return region;
}

- (BOOL)authorizedLocation
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        return true;
    } return false;
}

- (BOOL)deniedLocation
{
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied;
}

- (void)setupCoreLocation
{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"authorized always");
            [self.delegate locationAuthorized:YES];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"authorized when in use");
            [self.delegate locationAuthorized:YES];
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"denied");
            [self.delegate locationAuthorized:NO];
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"restricted");
            // disable button;
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"not determined");
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
                [self.locationManager requestAlwaysAuthorization];
            } else {
                [self.locationManager startUpdatingLocation];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Location Manger

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"did change authorize status");
    [self setupCoreLocation];
}



@end
