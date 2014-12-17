//
//  NTMapUtilities.h
//  seattle_schools
//
//  Created by Nate on 12/15/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

typedef struct {
    CLLocationDegrees left;
    CLLocationDegrees right;
    CLLocationDegrees top;
    CLLocationDegrees bottom;
}RegionBounds;

NS_INLINE RegionBounds RegionBoundsFromCoordinateRegion(MKCoordinateRegion region)
{
    RegionBounds bounds;
    bounds.left = region.center.longitude - region.span.longitudeDelta;
    bounds.right = region.center.longitude + region.span.longitudeDelta;
    bounds.top = region.center.latitude + region.span.latitudeDelta;
    bounds.bottom = region.center.latitude - region.span.latitudeDelta;
    return bounds;
}

NS_INLINE NSString *NSStringFromMKCoordinateRegion(MKCoordinateRegion region){
    return [NSString stringWithFormat:@"{ %f, %f } { %f, %f }", region.center.longitude,region.center.latitude, region.span.longitudeDelta, region.span.latitudeDelta];
}

NS_INLINE  MKCoordinateRegion MKCoordinateRegionsRestrictInBounds(MKCoordinateRegion inner, MKCoordinateRegion outer){
    // restrict zoom
    if(inner.span.latitudeDelta > outer.span.latitudeDelta)
        inner.span.latitudeDelta = outer.span.latitudeDelta;
    if(inner.span.longitudeDelta > outer.span.longitudeDelta)
        inner.span.longitudeDelta = outer.span.longitudeDelta;
    
    CLLocationDegrees scalar = 0.2;
    
    // restrict movement
    if(inner.center.longitude < outer.center.longitude - outer.span.longitudeDelta * scalar)
        inner.center.longitude = outer.center.longitude - outer.span.longitudeDelta * scalar;
    else if(inner.center.longitude > outer.center.longitude + outer.span.longitudeDelta * scalar)
        inner.center.longitude = outer.center.longitude + outer.span.longitudeDelta * scalar;
    
    if(inner.center.latitude < outer.center.latitude - outer.span.latitudeDelta * scalar)
        inner.center.latitude = outer.center.latitude - outer.span.latitudeDelta * scalar;
    else if(inner.center.latitude > outer.center.latitude + outer.span.latitudeDelta * scalar)
        inner.center.latitude = outer.center.latitude + outer.span.latitudeDelta * scalar;
    
    return inner;
}
