//
//  NTJSONNetworkCollector+Google.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTJSONNetworkCollector+Google.h"
#import "NSDictionary+Null.h"
#import "NTGlobal.h"

@implementation NTJSONNetworkCollector (Google)

- (void)retrieveImageWithHandler:(NTNetworkRetrieveImage)handler withKeyword:(NSString *)keyword;
{
    // validate keyword. return if none.
    if(!keyword) {
        handler(nil, nil);
        return;
    }
    
    __weak typeof (self) weakself = self;
    __block NSString *path = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", keyword];
    
    // request image data from google search
    [self retrieveDictionaryWithHandler:^(NSDictionary *dict, NSError *error) {
        if (error) {
            handler(nil, error);
            NTLogTitleMessage(path, error.localizedDescription);
            return;
        }
        
        
        // validatate reponse status
        NSInteger status = [dict[@"responseStatus"] integerValue];
        if(  status < 200 || status > 200 || [dict[@"responseData"] isKindOfClass:[NSNull class]]) {
            NSString *detail = dict[@"responseDetails"];
            NSError *error = [NSError errorWithDomain:[NTDataCollectorDomain stringByAppendingString:@".http"]
                                                 code:status
                                             userInfo:@{NSLocalizedDescriptionKey:detail}];
            handler(nil, error);
            return;
        }
        
        // retrieve first result
        NSDictionary *firstResult = [dict[@"responseData"][@"results"] firstObject];
        firstResult = firstResult.dictionaryByRemovingNull;
        
        // validate if their any results
        if (firstResult) {
            NSLog(@"%@", firstResult);
            NSString *urlPath = firstResult[@"tbUrl"];
            
            // After retrieving a result, request that image from result.
            [weakself retrieveImageFromURLWithHandler:^(UIImage *image, NSError *error) {
                handler(image, error);
            } atPath:urlPath];
        } else {
            NSError *error = [NSError errorWithDomain:NTDataCollectorDomain
                                                 code:103
                                             userInfo:@{NSLocalizedDescriptionKey:NTDataCollectorErrorNotFound}];
            handler(nil, error);
        }
    } atPath:path];
}

@end
