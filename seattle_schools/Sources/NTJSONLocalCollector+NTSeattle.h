//
//  NTJSONLocalCollector+NTSeattle.h
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDataCollector.h"

@interface NTJSONLocalCollector (NTSeattle)

/**
 *  This will retrieve data from local storage
 */
- (void)retrieveSchoolsWithHandler:(NTNetworkRetrieveCollection)handler;

@end
