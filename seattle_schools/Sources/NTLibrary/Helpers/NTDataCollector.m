//
//  NTDataNetwork.m
//  notes
//
//  Created by Nate on 12/1/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTDataCollector.h"
#import "NTGlobal.h"

NSString *const NTDataCollectorErrorRetrieveImage = @"Error for retrieving image.";
NSString *const NTDataCollectorErrorDataType = @"Error for mismatch data type.";
NSString *const NTDataCollectorErrorNotFound = @"Not Found.";
NSString *const NTDataCollectorDomain = @"com.ifcantel.schools";


@implementation NTDataCollector

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)retrieveImageFromURLWithHandler:(NTNetworkRetrieveImage)handler atPath:(NSString *)path
{
    __block NSURL *url = [NSURL URLWithString:path];
    __block UIImage *image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData  = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!image) {
                NSError *error = [NSError errorWithDomain:NTDataCollectorDomain
                                                     code:100
                                                 userInfo:@{NSLocalizedDescriptionKey:NTDataCollectorErrorRetrieveImage}];
                handler(nil, error);
            } else {
                NTLogTitleMessage(@"Image", @"Successfully retrieve image");
                handler(image, nil);
            }
        });
    });
}

@end

@implementation NTJSONNetworkCollector

- (void)retrieveCollectionWithHandler:(NTNetworkRetrieveCollection)handler atPath:(NSString *)path
{
    [self retrieveObjectWithHandler:^(id obj, NSError *error) {
        if (error)
            handler(obj, error);
        else {
            if(![obj isKindOfClass:[NSArray class]]) {
                NSError *error = [NSError errorWithDomain:NTDataCollectorDomain
                                                     code:101
                                                 userInfo:@{NSLocalizedDescriptionKey:NTDataCollectorErrorDataType}];
                handler(nil, error);
            } else {
                handler(obj, nil);
            }
        }
    } atPath:path];
}

- (void)retrieveDictionaryWithHandler:(NTNetworkRetrieveDictionary)handler atPath:(NSString *)path
{
    [self retrieveObjectWithHandler:^(id obj, NSError *error) {
        if (error)
            handler(obj, error);
        else {
            if(![obj isKindOfClass:[NSDictionary class]]) {
                NSError *error = [NSError errorWithDomain:NTDataCollectorDomain
                                                     code:101
                                                 userInfo:@{NSLocalizedDescriptionKey:NTDataCollectorErrorDataType}];
                handler(nil, error);
            } else {
                handler(obj, nil);
            }
        }
    } atPath:path];
}

- (void)retrieveObjectWithHandler:(NTNetworkRetrieveObject)handler atPath:(NSString *)path
{
    // create the sesssion
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // create the request
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // set the completion handler for the request.
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NTLogConnection(response.URL.absoluteString, @"", error); // Uncomment for logs
        
        // validate if error.
        if(error){
            handler(nil, error);
            return;
        }
        
        // convert json to object
        NSError *jsonError = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        if (error) {
            NSLog(@"Request Error: %@", jsonError.localizedDescription);
            handler(nil, error);
            return;
        }
        
        // otherwise pass the data up.
        handler(obj, nil);
    }];
    
    // execute request.
    [task resume];
}

@end

@implementation NTJSONLocalCollector

- (void)retrieveCollectionWithHandler:(NTNetworkRetrieveCollection)handler atPath:(NSString *)path
{
    [self retrieveObjectWithHandler:^(id obj, NSError *error) {
        if (error)
            handler(obj, error);
        else {
            if(![obj isKindOfClass:[NSArray class]]) {
                NSError *error = [NSError errorWithDomain:NTDataCollectorDomain
                                                     code:101
                                                 userInfo:@{NSLocalizedDescriptionKey:NTDataCollectorErrorDataType}];
                handler(nil, error);
            } else {
                handler(obj, nil);
            }
        }
    } atPath:path];
}

- (void)retrieveDictionaryWithHandler:(NTNetworkRetrieveDictionary)handler atPath:(NSString *)path
{
    [self retrieveObjectWithHandler:^(id obj, NSError *error) {
        if (error)
            handler(obj, error);
        else {
            if(![obj isKindOfClass:[NSDictionary class]]) {
                NSError *error = [NSError errorWithDomain:NTDataCollectorDomain
                                                     code:101
                                                 userInfo:@{NSLocalizedDescriptionKey:NTDataCollectorErrorDataType}];
                handler(nil, error);
            } else {
                handler(obj, nil);
            }
        }
    } atPath:path];
}

- (void)retrieveObjectWithHandler:(NTNetworkRetrieveObject)handler atPath:(NSString *)path
{
    __block NSURL *url = [NSURL fileURLWithPath:path];
    __block id obj = nil;
    __block NSError *error = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NTLogConnection(path, @"", error); // Uncomment for logs
        
        NSData *data  = [[NSData alloc] initWithContentsOfURL:url options:0 error:&error];
        
        // validate if error.
        if (!error) {
            // convert json to object
            obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(obj, error);
        });
    });
}

@end