//
//  NTJSONNetworkCollector+Google.m
//  seattle_schools
//
//  Created by Nate on 12/17/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTJSONNetworkCollector+Google.h"
#import "NSDictionary+Null.h"

@implementation NTJSONNetworkCollector (Google)

- (void)retrieveImageWithHandler:(NTNetworkRetrieveImage)handler withKeyword:(NSString *)keyword;
{
    keyword = [keyword stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    
    __weak typeof (self) weakself = self;
    NSString *path = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", keyword];
//    path = @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=www.ckseattle.org";
    [self retrieveDictionaryWithHandler:^(NSDictionary *dict, NSError *error) {
        
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
        
        NSDictionary *firstResult = [dict[@"responseData"][@"results"] firstObject];
        firstResult = firstResult.dictionaryByRemovingNull;
        
        if (firstResult) {
            NSLog(@"%@", firstResult);
            NSString *urlPath = firstResult[@"tbUrl"];
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
