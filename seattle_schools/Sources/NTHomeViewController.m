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
#import "NTPanGestureRecognizer.h"

static const CGFloat min = 120;
static const CGFloat max = 300;

static const CGFloat leeway = 100;

static const MKCoordinateRegion kBoundRegion = {{ 47.6425199, -122.3210886}, {1.0, 1.0}};

@interface NTHomeViewController ()<MKMapViewDelegate, NTLocationManagerDelegate, NTFilterViewControllerDelegate>
@property (nonatomic) NTJSONLocalCollector *network;
@property (nonatomic) NSMutableArray *schools;
@property (nonatomic) NTFilterViewController *filterVC;
@property (nonatomic) NTLocationManager *locationManager;
@property (nonatomic) BOOL rendered;
@property (nonatomic) CGFloat zoomLevel;
@property (nonatomic) NSArray *filterSchools;
@property (weak, nonatomic) IBOutlet UIImageView *poleContainer;
@property (nonatomic) UIView *poleView;
@property (nonatomic) UIView *poleMiddleView;
@property (nonatomic) CGPoint lastPosition;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation NTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _schools = [NSMutableArray array];
    _network = [NTJSONLocalCollector sharedInstance];
    _lastPosition = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    // set location manager
    _locationManager = [NTLocationManager sharedInstance];
    [_locationManager setDelegate:self];
    
    CGSize viewSize = self.view.frame.size;
    
    // create pole view
    self.poleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.poleContainer.frame.size.width, viewSize.height * 2.0f)];
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_tile"]];
    [self.poleView setBackgroundColor:patternColor];
    [self.poleContainer addSubview:self.poleView];
    [self.poleContainer setClipsToBounds:YES];
    CGFloat poleWidth = self.view.frame.size.width * .9f;
    CGRect middle = CGRectMake((viewSize.width - poleWidth) * .5, 0, poleWidth, self.poleContainer.frame.size.height);
    UIView *poleMiddleView = [[UIView alloc] initWithFrame:middle];
    [poleMiddleView setBackgroundColor:[UIColor whiteColor]];
    _poleMiddleView = poleMiddleView;
    [self.poleContainer addSubview:poleMiddleView];
    
    
    // add filter view controller
    _filterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"filterViewController"];
    [_filterVC setDelegate:self];
    [self addChildViewController:_filterVC];
    [self.view addSubview:_filterVC.view];
    CGRect frame =  _filterVC.view.frame;
    frame.origin.y = -frame.size.height + 200;
    frame.size.width = poleWidth;
    frame.origin.x = (viewSize.width - poleWidth) * .5;
    _filterVC.view.frame = frame;
    
    // add current location button
//    MKUserTrackingBarButtonItem *trackingItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
//    [self.navigationItem setLeftBarButtonItem:trackingItem];

    // set mapview
    [self.mapView setDelegate:self];

    // retrieve data
    [self retrieveSchools];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id<MKAnnotation> annotation = self.mapView.selectedAnnotations.lastObject;
    if ([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
        NTDetailViewController *vc = segue.destinationViewController;
        [vc setSchool:[(id)annotation school]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


#pragma mark - Other Functions

- (void)showCurrentLocation
{
    if (![self.locationManager authorizedLocation]) return;
    [self.mapView setRegion:[self.locationManager regionByCurrentLocation]  animated:YES];
}

#pragma mark - Network Call

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

#pragma mark - Schools & Filter

- (void)addSchools:(NSArray *)schools
{
    // remove school name duplications
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[schools sortedArrayUsingDescriptors:@[ sort ]]];
    for (int i = 0; i < tempArray.count-1; i++) {
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
    static NSString *current = @"current";
    
    NSString *identifier;
    if ( [annotation isKindOfClass:[NTSchoolGroupAnnotation class]] ) {
        identifier = schoolIdentifier;
    } else {
        identifier = current;
    }
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:schoolIdentifier];
    if (!view) {
        if ( [annotation isKindOfClass:[NTSchoolGroupAnnotation class]] ) {
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
    
    // validate if NTGroupAnnotation class. MKUserLocation annotate might come through.
    if ( [annotation isKindOfClass:[NTSchoolGroupAnnotation class]] ) {
        
        // set pin image
        __block NTSchool *school = [((NTSchoolGroupAnnotation *)annotation) firstObject];
        [view setImage:[(NTSchoolGroupAnnotation*)annotation image]];
        
        // set tag for button
        NSUInteger index = [self.schools containsObject:school];
        [view.rightCalloutAccessoryView setTag:index];
    }
    
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
            
            // there is no school image, grab image from network
//            [[NTJSONNetworkCollector sharedInstance] retrieveImageWithHandler:^(UIImage *image, NSError *error) {
//                [school setImage:image];
//                [iv setImage:image];
//            } withKeyword:school.website];
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
    NSLog(@"frame: %@", NSStringFromCGRect(rect));
    
    CGRect frame = CGRectSetY(self.poleView.frame, rect.origin.y - self.poleView.frame.size.height/2);
    [self.poleView setFrame:frame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    CGPoint point = [touches.anyObject locationInView:self.view];
    NSLog(@"MAIN begin touch: %@", NSStringFromCGPoint(point));
}


@end
