//
//  NTJSONLocalCollector+NTSeattle.h
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDataCollector.h"

@interface NTJSONLocalCollector (NTSeattle)

- (void)retrieveSchoolsWithHandler:(NTNetworkRetrieveCollection)handler;

@end
