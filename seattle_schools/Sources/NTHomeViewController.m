//
//  ViewController.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTHomeViewController.h"
#import <CoreLocation/CoreLocation.h>

#import "NTJSONNetworkCollector+Google.h"
#import "NTJSONNetworkCollector+NTSeattle.h"
#import "NTJSONLocalCollector+NTSeattle.h"
#import "UIAlertView+NTShow.h"
#import "NTGlobal.h"
#import "NTFilterViewController.h"
#import "NTLocationManager.h"
#import "NTMapUtilities.h"
#import "NTSchoolAnnotate.h"
#import "NTDetailViewController.h"
#import "NTSchoolFilter.h"

static const MKCoordinateRegion kBoundRegion = {{ 47.6425199, -122.3210886}, {1.0, 1.0}};

@interface NTHomeViewController ()<MKMapViewDelegate, NTLocationManagerDelegate, NTFilterViewControllerDelegate>
@property (nonatomic) NTJSONNetworkCollector *network;
@property (nonatomic) NSMutableArray *schools;
@property (nonatomic) NTFilterViewController *filterVC;
@property (nonatomic) NTLocationManager *locationManager;
@property (nonatomic) BOOL modifyingMap;
@property (nonatomic) BOOL rendered;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CGFloat zoomLevel;
@property (nonatomic) NSArray *filterSchools;
@end

@implementation NTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _schools = [NSMutableArray array];
    _network = [NTJSONNetworkCollector sharedInstance];
    _locationManager = [NTLocationManager sharedInstance];
    [_locationManager setDelegate:self];
    
    
    // add filter view controller
    _filterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"filterViewController"];
    [_filterVC setDelegate:self];
    [self addChildViewController:_filterVC];
    [self.view addSubview:_filterVC.view];
    CGRect frame =  _filterVC.view.frame;
    frame.origin.y = -frame.size.height + 200;
    _filterVC.view.frame = frame;
    
    // add current location button
    MKUserTrackingBarButtonItem *trackingItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    [self.navigationItem setLeftBarButtonItem:trackingItem];
    
    // set mapview
    [self.mapView setDelegate:self];

    // retrieve data
    [self retrieveSchools];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id<MKAnnotation> annotation = self.mapView.selectedAnnotations.lastObject;
    if ([annotation isKindOfClass:[NTSchoolAnnotate class]]) {
        NTDetailViewController *vc = segue.destinationViewController;
        [vc setSchool:[(id)annotation school]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)retrieveSchools
{
    __weak typeof(self) weakself = self;
    [_network retrieveSchoolsWithHandler:^(NSArray *items, NSError *error) {
        if(error) {
            [UIAlertView showAlertWithMessage:error.localizedDescription];
        } else {
            [weakself addSchools:items];
        }
    }];
}

- (void)addSchools:(NSArray *)schools
{
    [self.schools addObjectsFromArray:schools];
    self.filterSchools = self.schools;
    [self addSchoolAnnotationsWithSchools:self.filterSchools];
}

- (void)addSchoolAnnotationsWithSchools:(NSArray *)schools
{
    NSMutableArray *annotations = [NSMutableArray array];
    for (NTSchool *school in schools) {
        [annotations addObject:[[NTSchoolAnnotate alloc] initWithSchool:school]];
    }
    [self.mapView addAnnotations:annotations];
}

- (void)showCurrentLocation
{
    if (![self.locationManager authorizedLocation]) return;
    [self.mapView setRegion:[self.locationManager regionByCurrentLocation]  animated:YES];
}

#pragma mark - Actions

- (IBAction)selectCurrentLocation:(id)sender {
    [self showCurrentLocation];
}

#pragma mark - Map View Delegate

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    [self showCurrentLocation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // prevent restricting until map is fully rendered
    if(!self.rendered) return;
    
    // restrict map region to bounds
    MKCoordinateRegion mapRegion = self.mapView.region;
    mapRegion = MKCoordinateRegionsRestrictInBounds(mapRegion, kBoundRegion);
    
    // reset map view with new region
    [self.mapView setRegion:mapRegion animated:YES];
    
    
    if (self.zoomLevel!=mapView.region.span.longitudeDelta) {
        [self filterAnnotations:self.filterSchools];
        self.zoomLevel=mapView.region.span.longitudeDelta;
    }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    self.rendered = YES;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"views: %i", (int32_t)views.count);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *schoolIdentifier = @"school";
    static NSString *current = @"current";
    
    NSString *identifier;
    if ( [annotation isKindOfClass:[NTSchoolAnnotate class]] ) {
        identifier = schoolIdentifier;
    } else {
        identifier = current;
    }
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:schoolIdentifier];
    if (!view) {
        if ( [annotation isKindOfClass:[NTSchoolAnnotate class]] ) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [view setEnabled:YES];
            [view setCanShowCallout:YES];
            
            // create accessory button to view more detail about school.
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(selectCallOutButton:) forControlEvents:UIControlEventTouchUpInside];
            view.rightCalloutAccessoryView = rightButton;
            
            // create left accessory image
            UIImageView *iv = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"school47"]];
            view.leftCalloutAccessoryView = iv;
        } else {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [(MKPinAnnotationView *)view setPinColor:MKPinAnnotationColorGreen];
        }
    } else {
        
        [view setAnnotation:annotation];
    }
    
    
    
    // validate if NTSchoolAnnotate class. MKUserLocation annotate might come through.
    if ( [annotation isKindOfClass:[NTSchoolAnnotate class]] ) {
        // set pin image
        [view setImage:[UIImage imageNamed:@"school7"]];
        
        __block NTSchool *school = [((NTSchoolAnnotate *)annotation) school];
        
        // set tag for button
        NSUInteger index = [self.schools containsObject:school];
        [view.rightCalloutAccessoryView setTag:index];
        
//        // set image for callout
//        __block UIImageView *iv = (id)view.leftCalloutAccessoryView;
//        if(school.image) {
//            [iv setImage:school.image];
//        } else {
//            [self.network retrieveImageWithHandler:^(UIImage *image, NSError *error) {
//                [school setImage:image];
//                [iv setImage:image];
//            } withKeyword:school.website];
//        }
    }
    
    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // validate if NTSchoolAnnotate class. MKUserLocation annotate might come through.
    if ( [view.annotation isKindOfClass:[NTSchoolAnnotate class]] ) {
        __block NTSchool *school = [((NTSchoolAnnotate *)view.annotation) school];
        
        // set image for callout
        __block UIImageView *iv = (id)view.leftCalloutAccessoryView;
        if(school.image) {
            [iv setImage:school.image];
        } else {
            [self.network retrieveImageWithHandler:^(UIImage *image, NSError *error) {
                [school setImage:image];
                [iv setImage:image];
            } withKeyword:school.website];
        }
    }
}

- (void)selectCallOutButton:(UIButton *)button
{
    [self performSegueWithIdentifier:@"detail" sender:self];
}

-(void)filterAnnotations:(NSArray *)placesToFilter{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CGFloat annotationWidth = 32;
    CGFloat annotationHeight = 29;
    
    CGFloat iphoneScaleFactorLatitude = self.view.frame.size.width / annotationWidth;
    CGFloat iphoneScaleFactorLongitude = self.view.frame.size.height / annotationHeight;
    
    float latDelta=self.mapView.region.span.latitudeDelta/iphoneScaleFactorLatitude;
    float longDelta=self.mapView.region.span.longitudeDelta/iphoneScaleFactorLongitude;
    NSMutableArray *displayAnnotations=[[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=0; i<[placesToFilter count]; i++) {
        NTSchool *checkingLocation = (id)placesToFilter[i];
        CLLocationDegrees latitude = checkingLocation.latitude.doubleValue;
        CLLocationDegrees longitude = checkingLocation.longitude.doubleValue;
        bool found=FALSE;
        for (NTSchool *school in displayAnnotations) {
            if(fabs(school.latitude.doubleValue-latitude) < latDelta &&
               fabs(school.longitude.doubleValue-longitude) < longDelta ){
                found=TRUE;
                break;
            }
        }
        if (!found) {
            [displayAnnotations addObject:checkingLocation];
            [self addSchoolAnnotationsWithSchools:@[checkingLocation]];
            
//            [displayAnnotations addObject:checkingLocation];
//            [self.mapView addAnnotation:checkingLocation];
        }
    }
}

//-(void)filterAnnotations:(NSArray *)placesToFilter{
//    CGFloat annotationWidth = 32;
//    CGFloat annotationHeight = 29;
//    
//    CGFloat iphoneScaleFactorLatitude = self.view.frame.size.width / annotationWidth;
//    CGFloat iphoneScaleFactorLongitude = self.view.frame.size.height / annotationHeight;
//
//    float latDelta=self.mapView.region.span.latitudeDelta/iphoneScaleFactorLatitude;
//    float longDelta=self.mapView.region.span.longitudeDelta/iphoneScaleFactorLongitude;
//    NSMutableArray *displayAnnotations=[[NSMutableArray alloc] initWithCapacity:0];
//    
//    for (int i=0; i<[placesToFilter count]; i++) {
//        id<MKAnnotation> checkingLocation = (id)placesToFilter[i];
//        CLLocationDegrees latitude = [checkingLocation coordinate].latitude;
//        CLLocationDegrees longitude = [checkingLocation coordinate].longitude;
//        bool found=FALSE;
//        for (id<MKAnnotation> temp in displayAnnotations) {
//            if(fabs([temp coordinate].latitude-latitude) < latDelta &&
//               fabs([temp coordinate].longitude-longitude) < longDelta ){
//                [self.mapView removeAnnotation:checkingLocation];
//                found=TRUE;
//                break;
//            }
//        }
//        if (!found) {
//            [displayAnnotations addObject:checkingLocation];
//            [self.mapView addAnnotation:checkingLocation];
//        }
//    }
//}


#pragma mark - Location Manager

- (void)locationAuthorized:(BOOL)authorized
{
    if (authorized) {
        if (!self.mapView.showsUserLocation) self.mapView.showsUserLocation = YES;
        [self showCurrentLocation];
    } else {
        [UIAlertView showWithTitle:@"Error" message:@"Location Denied"];
    }
}

#pragma mark - Filter Delegate

- (void)filterViewControllerDidChangePredicate:(id<NTFilterProvider>)filter
{
    NSPredicate *predicate = [filter predicate];
    if(predicate) {
        NSLog(@"predicate: %@", predicate.description);
        NSArray *keptSchools = [self.schools filteredArrayUsingPredicate:predicate];
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.filterSchools = keptSchools;
        [self addSchoolAnnotationsWithSchools:self.filterSchools];
    } else {
        // show all schools
        
        NSLog(@"Show all schools");
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.filterSchools = self.schools;
        [self addSchoolAnnotationsWithSchools:self.filterSchools];
    }
}


@end
