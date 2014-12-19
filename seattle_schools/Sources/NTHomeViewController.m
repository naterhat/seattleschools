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
//#import "NTSchoolAnnotate.h"
#import "NTDetailViewController.h"
#import "NTSchoolFilter.h"
#import "UIImage+NTExtra.h"
#import "NTSchoolGroupAnnotation.h"

static const MKCoordinateRegion kBoundRegion = {{ 47.6425199, -122.3210886}, {1.0, 1.0}};

@interface NTHomeViewController ()<MKMapViewDelegate, NTLocationManagerDelegate, NTFilterViewControllerDelegate>
@property (nonatomic) NTJSONLocalCollector *network;
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
    _network = [NTJSONLocalCollector sharedInstance];
    
    // set location manager
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
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[schools sortedArrayUsingDescriptors:@[ sort ]]];
    for (int i = 0; i < tempArray.count-1; i++) {
        if ( [[tempArray[i] name] isEqualToString:[tempArray[i+1] name]] ) {
            [tempArray removeObject:tempArray[i+1]];
        }
    }
    
//    NSPredicate *template = [NSPredicate predicateWithFormat:@"name = $name"];
//    for (NTSchool *school in schools) {
//        NSDictionary *dict = @{@"name": school.name};
//        NSPredicate *pred = [template predicateWithSubstitutionVariables:dict];
//        if ([[self.schools filteredArrayUsingPredicate:pred] firstObject] == nil) {
//            [self.schools addObjectsFromArray:schools];
//        }
//    }
    
    self.schools = tempArray;
    self.filterSchools = tempArray;
    [self addSchoolAnnotationsWithSchools:self.filterSchools];
}

- (void)filterWithPredicate:(NSPredicate *)predicate
{
    NSInteger oldFilterCount = self.filterSchools.count;
    
    if(predicate) {
        NSLog(@"predicate: %@", predicate.description);
//        [self.mapView removeAnnotations:self.mapView.annotations];
        
        NSMutableArray *added = [NSMutableArray array];
        NSMutableArray *removed = [NSMutableArray array];
        
        [self filterSchoolsWithPredicate:predicate addedItems:added removedItems:removed];
        
        NSLog(@"Old: %i. New: %i. { +%i, -%i}",  (int32_t)oldFilterCount, (int32_t)self.filterSchools.count, (int32_t)added.count, (int32_t)removed.count);
        
//        [self addSchoolAnnotationsWithSchools:added];
//        [self removeSchoolAnnotationsWithSchools:removed];
        
        [self refreshAnnotationsWithSchoolFilter:self.filterSchools];
        
//        self.filterSchools = keptSchools;
//        [self addSchoolAnnotationsWithSchools:self.filterSchools];
    } else {
        // show all schools
        
        NSLog(@"Show all schools");
//        [self.mapView removeAnnotations:self.mapView.annotations];
//        self.filterSchools = self.schools;
//        [self addSchoolAnnotationsWithSchools:self.filterSchools];
        
        NSMutableArray *added = [NSMutableArray array];
        NSMutableArray *removed = [NSMutableArray array];
        
        [self filterSchoolsWithPredicate:nil addedItems:added removedItems:removed];
        
        NSLog(@"Old: %i. New: %i. { +%i, -%i}",  (int32_t)oldFilterCount, (int32_t)self.filterSchools.count, (int32_t)added.count, (int32_t)removed.count);
        
//        [self addSchoolAnnotationsWithSchools:added];
//        [self removeSchoolAnnotationsWithSchools:removed];
        
        [self refreshAnnotationsWithSchoolFilter:self.filterSchools];
    }
}

- (void)filterSchoolsWithPredicate:(NSPredicate *)predicate addedItems:(NSMutableArray *)added removedItems:(NSMutableArray *)removed
{
    NSMutableArray *oldArray, *newArray;
    
    oldArray = [NSMutableArray arrayWithArray:self.filterSchools];
    if(predicate)
        newArray = [NSMutableArray arrayWithArray: [self.schools filteredArrayUsingPredicate:predicate]];
    else
        newArray = self.schools;
    
    NSSortDescriptor *sortName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *sortPublic = [NSSortDescriptor sortDescriptorWithKey:@"public" ascending:YES];
    [oldArray sortUsingDescriptors:@[sortName, sortPublic]];
    [newArray sortUsingDescriptors:@[sortName, sortPublic]];
    
    NTSchool *oldSchool, *newSchool;
    int oldIndex = 0;
    int newIndex = 0;
    while (oldIndex < oldArray.count && newIndex < newArray.count) {
        oldSchool = oldArray[oldIndex];
        newSchool = newArray[newIndex];
        
        NSComparisonResult result = [oldSchool.name compare:newSchool.name options:NSLiteralSearch];
        
        if (result == NSOrderedAscending) {
            // removed
            [removed addObject:oldSchool];
            oldIndex++;
        } else if (result == NSOrderedDescending) {
            // added
            [added addObject:newSchool];
            newIndex++;
        } else {
            newIndex++; oldIndex++;
        }
    }
    
    // remove
    while (oldIndex < oldArray.count) {
        // removed
        [removed addObject:oldArray[oldIndex]];
        oldIndex++;
    }
    
    // add
    while (newIndex < newArray.count) {
        [added addObject:newArray[newIndex]];
        newIndex++;
    }
    
    // set filter
    self.filterSchools = newArray;
}

#pragma mark - Annotations

- (void)refresh
{
    NSLog(@"REFRESH");
    
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    
//    CGFloat annotationWidth = 32;
//    CGFloat annotationHeight = 29;
//    
//    CGFloat iphoneScaleFactorLatitude = self.view.frame.size.width / annotationWidth;
//    CGFloat iphoneScaleFactorLongitude = self.view.frame.size.height / annotationHeight;
//    
//    float latDelta=self.mapView.region.span.latitudeDelta/iphoneScaleFactorLatitude;
//    float longDelta=self.mapView.region.span.longitudeDelta/iphoneScaleFactorLongitude;
//    
//    for (int i=0; i<[self.filterSchools count]; i++) {
//        NTSchool *school = self.filterSchools[i];
//        CLLocationDegrees latitude = school.latitude.doubleValue;
//        CLLocationDegrees longitude = school.longitude.doubleValue;
//        bool found=FALSE;
//        for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
//            
//            if (![annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) continue;
//            
//            CLLocationCoordinate2D coord = annotation.coordinate;
//            if(fabs(coord.latitude-latitude) < latDelta &&
//               fabs(coord.longitude-longitude) < longDelta ){
//                found=TRUE;
//                [annotation addObject:school];
//                break;
//            }
//        }
//        if (!found) {
//            // Create Group Annotation
//            NTSchoolGroupAnnotation *group = [[NTSchoolGroupAnnotation alloc] initWithSchool:school];
//            [self.mapView addAnnotation:group];
//        }
//    }
}

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
        bool found=FALSE;
        for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
            
            if (![annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) continue;
            
            CLLocationCoordinate2D coord = annotation.coordinate;
            if(fabs(coord.latitude-latitude) < latDelta &&
               fabs(coord.longitude-longitude) < longDelta ){
                found=TRUE;
                [annotation addObject:school];
                
                MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
                [view setImage:annotation.image];
                break;
            }
        }
        if (!found) {
            // Create Group Annotation
            NTSchoolGroupAnnotation *group = [[NTSchoolGroupAnnotation alloc] initWithSchool:school];
            [self.mapView addAnnotation:group];
        }
    }
    
    // clear all annotation that are empty
    for (int i = (int)self.mapView.annotations.count-1; i >= 0; i--) {
        NTSchoolGroupAnnotation *annotation = self.mapView.annotations[i];
        if ([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
            if(annotation.isEmpty) {
                [self.mapView removeAnnotation:annotation];
            } else {
            }
        }
    }
    
    
    int viewCounts = 0;
    int annCount = 0;
    for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
        if([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
            viewCounts += annotation.count;
            annCount++;
        }
    }
    
    NSLog(@"Annotations: %i, Filter: %i, Ann Collection Total: %i", (int32_t)annCount, (int32_t)self.filterSchools.count, (int32_t)viewCounts);
}

- (void)addSchoolAnnotationsWithSchools:(NSArray *)schools{
    NSLog(@"ADD ANNOTATIONS");
    
//    CGFloat annotationWidth = 32;
//    CGFloat annotationHeight = 29;
//    
//    CGFloat iphoneScaleFactorLatitude = self.view.frame.size.width / annotationWidth;
//    CGFloat iphoneScaleFactorLongitude = self.view.frame.size.height / annotationHeight;
//    
//    float latDelta=self.mapView.region.span.latitudeDelta/iphoneScaleFactorLatitude;
//    float longDelta=self.mapView.region.span.longitudeDelta/iphoneScaleFactorLongitude;
//    
//    for (int i=0; i<[schools count]; i++) {
//        NTSchool *school = schools[i];
//        CLLocationDegrees latitude = school.latitude.doubleValue;
//        CLLocationDegrees longitude = school.longitude.doubleValue;
//        bool found=FALSE;
//        for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
//            
//            if (![annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) continue;
//            
//            CLLocationCoordinate2D coord = annotation.coordinate;
//            if(fabs(coord.latitude-latitude) < latDelta &&
//               fabs(coord.longitude-longitude) < longDelta ){
//                found=TRUE;
//                [annotation addObject:school];
//                break;
//            }
//        }
//        if (!found) {
//            // Create Group Annotation
//            NTSchoolGroupAnnotation *group = [[NTSchoolGroupAnnotation alloc] initWithSchool:school];
//            [self.mapView addAnnotation:group];
//        }
//    }
//    
//    int total = 0;
//    for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
//        if([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
//            total += annotation.count;
//        }
//    }
//    
//    NSLog(@"Filter: %i, Views: %i", (int32_t)self.filterSchools.count, (int32_t)total);
    
}

- (void)removeSchoolAnnotationsWithSchools:(NSArray *)schools{
    NSLog(@"REMOVE ANNOTATIONS");
    
//    for (NTSchool *school in schools) {
//        for(int i = (int)self.mapView.annotations.count-1; i>= 0;i--) {
//            NTSchoolGroupAnnotation *annotation =  self.mapView.annotations[i];
//            
//            if (![annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) continue;
//            
//            NSUInteger index = [annotation indexOfObject:school];
//            if(index != NSNotFound) {
//                [annotation removeObjectAtIndex:index];
//                if (annotation.isEmpty) {
//                    [self.mapView removeAnnotation:annotation];
//                } else {
//                    // this does nothing, but refresh the annotation view
////                    [annotation setCoordinate:CLLocationCoordinate2DMake(0, 0)];
//                    [self.mapView viewForAnnotation:annotation];
//                    
//                    MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
//                    [view setImage:annotation.image];
//                }
//                break;
//            }
//        }
//    }
//    
//    
//    int total = 0;
//    for (NTSchoolGroupAnnotation *annotation in self.mapView.annotations) {
//        if([annotation isKindOfClass:[NTSchoolGroupAnnotation class]]) {
//            total += annotation.count;
//        }
//    }
//    
//    NSLog(@"Filter: %i, Views: %i", (int32_t)self.filterSchools.count, (int32_t)total);
}


//- (void)addSchoolAnnotationsWithSchools:(NSArray *)schools
//{
//    NSMutableArray *annotations = [NSMutableArray array];
//    for (NTSchool *school in schools) {
//        [annotations addObject:[[NTSchoolGroupAnnotation alloc] initWithSchool:school]];
//    }
//    [self.mapView addAnnotations:annotations];
//}

//- (void)removeSchoolAnnotationsWithSchools:(NSArray *)schools
//{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"annotation = $school"];
//    NSMutableArray *annotations = [NSMutableArray array];
//    for (NTSchool *school in schools) {
//        predicate
//        [annotations addObject:[[NTGroupAnnotation alloc] initWithSchool:school]];
//    }
//    [self.mapView addAnnotations:annotations];
//}

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
        [self refresh];
//        [self filterAnnotations:self.filterSchools];
//        [self refreshAnnotations];
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
    // validate if NTGroupAnnotation class. MKUserLocation annotate might come through.
    if ( [view.annotation isKindOfClass:[NTSchoolGroupAnnotation class]] ) {
        NTSchoolGroupAnnotation *annotation = (id)view.annotation;
        __block NTSchool *school = [annotation firstObject ];
        
        // set image for callout
        __block UIImageView *iv = (id)view.leftCalloutAccessoryView;
        if(school.image) {
            [iv setImage:school.image];
        } else {
//            [self.network retrieveImageWithHandler:^(UIImage *image, NSError *error) {
//                [school setImage:image];
//                [iv setImage:image];
//            } withKeyword:school.website];
        }
    }
}


//-(void)filterAnnotations:(NSArray *)placesToFilter{
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    
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
//        NTSchool *checkingLocation = (id)placesToFilter[i];
//        CLLocationDegrees latitude = checkingLocation.latitude.doubleValue;
//        CLLocationDegrees longitude = checkingLocation.longitude.doubleValue;
//        bool found=FALSE;
//        for (NTSchool *school in displayAnnotations) {
//            if(fabs(school.latitude.doubleValue-latitude) < latDelta &&
//               fabs(school.longitude.doubleValue-longitude) < longDelta ){
//                found=TRUE;
//                break;
//            }
//        }
//        if (!found) {
//            [displayAnnotations addObject:checkingLocation];
//            [self addSchoolAnnotationsWithSchools:@[checkingLocation]];
//            
////            [displayAnnotations addObject:checkingLocation];
////            [self.mapView addAnnotation:checkingLocation];
//        }
//    }
//}

-(void)filterAnnotations:(NSArray *)placesToFilter{
    CGFloat annotationWidth = 32;
    CGFloat annotationHeight = 29;
    
    CGFloat iphoneScaleFactorLatitude = self.view.frame.size.width / annotationWidth;
    CGFloat iphoneScaleFactorLongitude = self.view.frame.size.height / annotationHeight;

    float latDelta=self.mapView.region.span.latitudeDelta/iphoneScaleFactorLatitude;
    float longDelta=self.mapView.region.span.longitudeDelta/iphoneScaleFactorLongitude;
    NSMutableArray *displayAnnotations=[[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=0; i<[placesToFilter count]; i++) {
        id<MKAnnotation> checkingLocation = (id)placesToFilter[i];
        CLLocationDegrees latitude = [checkingLocation coordinate].latitude;
        CLLocationDegrees longitude = [checkingLocation coordinate].longitude;
        bool found=FALSE;
        for (id<MKAnnotation> temp in displayAnnotations) {
            if(fabs([temp coordinate].latitude-latitude) < latDelta &&
               fabs([temp coordinate].longitude-longitude) < longDelta ){
                [self.mapView removeAnnotation:checkingLocation];
                found=TRUE;
                break;
            }
        }
        if (!found) {
            [displayAnnotations addObject:checkingLocation];
            [self.mapView addAnnotation:checkingLocation];
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


@end
