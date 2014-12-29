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
#import "NTDetailViewController.h"
#import "NTSchoolFilter.h"
#import "UIImage+NTExtra.h"
#import "NTSchoolGroupAnnotation.h"
#import "NTMath.h"
#import "NTPoleView.h"
#import "NTTheme.h"
#import "NTFilterTransformView.h"
#import "NTFilterContainer.h"
#import "Reachability.h"
#import "NTMessageView.h"

static const MKCoordinateRegion kBoundRegion = {{ 47.6425199, -122.3210886}, {1.0, 1.0}};

@interface NTHomeViewController ()<MKMapViewDelegate, NTLocationManagerDelegate, NTFilterViewControllerDelegate>

@property (nonatomic) BOOL internetConnected;
@property (nonatomic) BOOL rendered;
@property (nonatomic) CGFloat zoomLevel;
@property (nonatomic) NSArray *filterSchools;
@property (nonatomic) NSMutableArray *schools;

@property (nonatomic) Reachability *reach;
@property (nonatomic) NTJSONNetworkCollector *network;
@property (nonatomic) NTFilterViewController *filterVC;
@property (nonatomic) NTLocationManager *locationManager;
@property (nonatomic) UIView *filterContainer;
@property (nonatomic) NTMessageView *noInternetMessageView;

@property (weak, nonatomic) IBOutlet NTPoleView *poleView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation NTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    _schools = [NSMutableArray array];
    _network = [NTJSONNetworkCollector sharedInstance];
    
    // set location manager
    _locationManager = [NTLocationManager sharedInstance];
    [_locationManager setDelegate:self];
    
    // load "no internet" message
    _noInternetMessageView = [[NTMessageView alloc] initWithMessage:@"NO INTERNET" center:self.view.center];
    [self.view addSubview:_noInternetMessageView];
    [_noInternetMessageView setHidden:YES];
    
    // set filter container.
    CGRect bounds = self.view.bounds;
    bounds.origin.y = 3;
    _filterContainer = [[NTFilterContainer alloc] initWithFrame:bounds];
    [_filterContainer setClipsToBounds:YES];
    [self.view addSubview:_filterContainer];
    
    // add filter view controller
    _filterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"filterViewController"];
    [_filterVC setDelegate:self];
    [self addChildViewController:_filterVC];
    [_filterContainer addSubview:_filterVC.view];
    
    // add light on top of pole
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 3, self.view.frame.size.width, 3)];
    [top setBackgroundColor:[UIColor colorWithWhite:1 alpha:.15]];
    [self.view addSubview:top];
    
    
    // add current location button
//    MKUserTrackingBarButtonItem *trackingItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
//    [self.navigationItem setLeftBarButtonItem:trackingItem];

    // set mapview
    [self.mapView setDelegate:self];
    
    [self loadReachability];

    // retrieve data
//    [self retrieveSchools];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id<MKAnnotation> annotation = self.mapView.selectedAnnotations.lastObject;
    if ([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
        NTDetailViewController *vc = segue.destinationViewController;
        [vc setSchool:[(id)annotation firstObject]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


#pragma mark - Other Functions

- (void)loadReachability
{
    // this will notify if internet is connected ot not. If not, display the appropiate message.
    __weak typeof(self) weakself = self;
    _reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // internet
    _reach.reachableBlock = ^(Reachability *reach) {
        NSLog(@"REACHABLE!");
        weakself.internetConnected = YES;
    };
    
    // no internet
    _reach.unreachableBlock = ^(Reachability *reach) {
        NSLog(@"UNREACHABLE");
        weakself.internetConnected = NO;
    };
    
    [_reach startNotifier];
}

- (void)setInternetConnected:(BOOL)internetConnected
{
    _internetConnected = internetConnected;
    
    // reload the views from the main thread
    dispatch_async( dispatch_get_main_queue(), ^ {
        
        if (_internetConnected) {
            // show map
            [self.mapView setHidden:NO];
            [self.noInternetMessageView setHidden:YES];
            
            [self retrieveSchools];
        } else {
            // validate if have not retrieve schools. display no internet.
            if(self.schools.count == 0) {
                // hide map
                [self.mapView setHidden:YES];
                [self.noInternetMessageView setHidden:NO];
            }
        }
    });
}


- (void)showCurrentLocation
{
    if (![self.locationManager authorizedLocation]) return;
    [self.mapView setRegion:[self.locationManager regionByCurrentLocation]  animated:YES];
}

#pragma mark - Network Call

- (void)retrieveSchools
{
    // return if already retrieve schools.
    if(_schools.count > 0) return;
    
    __weak typeof(self) weakself = self;
    [_network retrieveSchoolsWithHandler:^(NSArray *items, NSError *error) {
        if(error) {
            [UIAlertView showAlertWithMessage:error.localizedDescription];
        } else {
            [weakself addSchools:items];
        }
    }];
}

#pragma mark - Schools & Filter

- (void)addSchools:(NSArray *)schools
{
    // remove school name duplications
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[schools sortedArrayUsingDescriptors:@[ sort ]]];
    int count = (int32_t)tempArray.count;
    for( int i = 0; i < count-2; i++) {
        if ( [[tempArray[i] name] isEqualToString:[tempArray[i+1] name]] ) {
            [tempArray removeObject:tempArray[i+1]];
        }
    }
    
    self.schools = tempArray;
    self.filterSchools = tempArray;
}

- (void)filterWithPredicate:(NSPredicate *)predicate
{
    if(predicate) {
        // Filter schools
        NSLog(@"Filter schools by %@", predicate.description);
        self.filterSchools = [NSMutableArray arrayWithArray: [self.schools filteredArrayUsingPredicate:predicate]];
        [self refreshAnnotationsWithSchoolFilter:self.filterSchools];

    } else {
        // show all schools
        NSLog(@"Show all schools");
        self.filterSchools = self.schools;
        [self refreshAnnotationsWithSchoolFilter:self.filterSchools];
    }
}

#pragma mark - Annotations

- (void)refreshAnnotationsWithSchoolFilter:(NSArray *)filter
{
    NSLog(@"REFRESH ANNOTATIONS");
    
    // set parameters to convert annotation coordinate to screen space.
    CGFloat annotationWidth = 40;
    CGFloat annotationHeight = 40;
    
    CGFloat scaleFactorLatitude = self.view.frame.size.width / annotationWidth;
    CGFloat scaleFactorLongitude = self.view.frame.size.height / annotationHeight;
    
    float latDelta=self.mapView.region.span.latitudeDelta/scaleFactorLatitude;
    float longDelta=self.mapView.region.span.longitudeDelta/scaleFactorLongitude;
    
    // clear all objects from annotations
    for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
            [annotation removeAllObjects];
        }
    }
    
    for (int i=0; i<[filter count]; i++) {
        NTSchool *school = filter[i];
        CLLocationDegrees latitude = school.latitude.doubleValue;
        CLLocationDegrees longitude = school.longitude.doubleValue;
        BOOL found=NO;
        for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
            
            if (![annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) continue;
            
            CLLocationCoordinate2D coord = annotation.coordinate;
            
            // If coordinate is inside the annotation, then add object to annotation
            //   collection and refresh view.
            if(fabs(coord.latitude-latitude) < latDelta &&
               fabs(coord.longitude-longitude) < longDelta ){
                found=YES;
                [annotation addObject:school];
                
                // set annotation image
                // AND enable and disable call out
                MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
                [view setImage:annotation.image];
                [view setEnabled:annotation.count == 1];
                break;
            }
        }
        if (!found) {
            // Create Group Annotation
            NTSchoolGroupAnnotation *group = [[NTSchoolGroupAnnotation alloc] initWithSchool:school];
            [self.mapView addAnnotation:group];
        }
    }
    
    // clear/remove all annotation that are empty
    for (int i = (int)self.mapView.annotations.count-1; i >= 0; i--) {
        NTSchoolGroupAnnotation *annotation = self.mapView.annotations[i];
        if ([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
            if (annotation.isEmpty) {
                [self.mapView removeAnnotation:annotation];
            }
        }
    }
    
    
    // DEBUG PURPOSES
    // ==============
    int viewCounts = 0;
    int annCount = 0;
    for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
            viewCounts += annotation.count;
            annCount++;
        }
    }
    NSLog(@"Annotations: %i, Filter: %i, Ann Collection Total: %i", (int32_t)annCount, (int32_t)self.filterSchools.count, (int32_t)viewCounts);
    // ==============
}

#pragma mark - Actions

- (IBAction)selectCurrentLocation:(id)sender {
    [self showCurrentLocation];
}

- (IBAction)selectCallOutButton:(UIButton *)button
{
    [self performSegueWithIdentifier:@"detail" sender:self];
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
        [self refreshAnnotationsWithSchoolFilter:self.filterSchools];
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
    
    // if user current location annotation, return nil
    if (! [annotation isKindOfClass:[NTSchoolGroupAnnotation class]] ) {
        return nil;
    }
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:schoolIdentifier];
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:schoolIdentifier];
        [view setEnabled:YES];
        [view setCanShowCallout:YES];
        
        // create accessory button to view more detail about school.
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(selectCallOutButton:) forControlEvents:UIControlEventTouchUpInside];
        view.rightCalloutAccessoryView = rightButton;
        
        // create left accessory image
        UIImageView *iv = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"school47"]];
        [iv setContentMode:UIViewContentModeScaleAspectFit];
        view.leftCalloutAccessoryView = iv;
    } else {
        
        [view setAnnotation:annotation];
    }
    
    // set pin image
    __block NTSchool *school = [((NTSchoolGroupAnnotation *)annotation) firstObject];
    [view setImage:[(NTSchoolGroupAnnotation*)annotation image]];
    
    // set tag for button
    NSUInteger index = [self.schools containsObject:school];
    [view.rightCalloutAccessoryView setTag:index];
    
    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // validate if NTGroupAnnotation class. MKUserLocation annotate might come through.
    if ( [view.annotation isKindOfClass:[NTSchoolGroupAnnotation class]] ) {
        NTSchoolGroupAnnotation *annotation = (id)view.annotation;
        __block NTSchool *school = [annotation firstObject ];
        
        // set image for callout
        __block UIImageView *iv = (id)view.leftCalloutAccessoryView;
        if(school.image) {
            [iv setImage:school.image];
        } else {
            
#warning "Working Progress to retrieve image from google api"
            // there is no school image, grab image from network
            [[NTJSONNetworkCollector sharedInstance] retrieveImageWithHandler:^(UIImage *image, NSError *error) {
                [school setImage:image];
                [iv setImage:image];
            } withKeyword:school.website];
        }
    }
}


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
    [self filterWithPredicate:predicate];
}

- (void)filterViewControllerUpdateFrame:(CGRect)rect
{
    // animate the scrolling of the pole.
    [self.poleView scrollToPosition:rect.origin];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    CGPoint point = [touches.anyObject locationInView:self.view];
    NSLog(@"MAIN begin touch: %@", NSStringFromCGPoint(point));
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


@end
