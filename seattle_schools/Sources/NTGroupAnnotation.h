//
//  NTGroupAnnotation.h
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface NTGroupAnnotation : NSObject<MKAnnotation>
@property (nonatomic) NSMutableArray *collection;
@end
