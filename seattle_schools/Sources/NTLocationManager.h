//
//  NTLocationManager.h
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol NTLocationManagerDelegate;

@interface NTLocationManager : NSObject
@property (nonatomic, weak)id<NTLocationManagerDelegate> delegate;
+ (instancetype)sharedInstance;
- (BOOL)deniedLocation;
- (BOOL)authorizedLocation;
- (MKCoordinateRegion)regionByCurrentLocation;
@end

@protocol NTLocationManagerDelegate <NSObject>
- (void)locationAuthorized:(BOOL)authorized;
@end