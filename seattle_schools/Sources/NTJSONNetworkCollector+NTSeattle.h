//
//  NTDataNetwork+NTSeattleNetwork.h
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDataCollector.h"

@interface NTJSONNetworkCollector (NTSeattle)

- (void)retrieveSchoolsWithHandler:(NTNetworkRetrieveCollection)handler;

@end
