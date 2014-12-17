//
//  NTDataNetwork+NTSeattleNetwork.h
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDataNetwork.h"

@interface NTDataNetwork (NTSeattleNetwork)

- (void)retrieveSchoolsWithHandler:(NTNetworkRetrieveCollection)handler;

@end
