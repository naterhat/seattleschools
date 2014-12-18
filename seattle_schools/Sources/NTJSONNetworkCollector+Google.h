//
//  NTJSONNetworkCollector+Google.h
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDataCollector.h"

@interface NTJSONNetworkCollector (Google)

- (void)retrieveImageWithHandler:(NTNetworkRetrieveImage)handler withKeyword:(NSString *)keyword;

@end
