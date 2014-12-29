//
//  NTDataNetwork.h
//  notes
//
//  Created by Nate on 12/1/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

NSString *const NTDataCollectorErrorRetrieveImage;
NSString *const NTDataCollectorErrorDataType;
NSString *const NTDataCollectorErrorNotFound;
NSString *const NTDataCollectorDomain;

typedef void(^NTNetworkRetrieveObject)(id obj, NSError *error);
typedef void(^NTNetworkRetrieveDictionary)(NSDictionary *dictionary, NSError *error);
typedef void(^NTNetworkRetrieveCollection)(NSArray *items, NSError *error);
typedef void(^NTNetworkRetrieveImage)(UIImage *image, NSError *error);

@protocol NTDataCollectorProtocol <NSObject>

+ (instancetype)sharedInstance;

/**
 *  Call to retrieve any object.
 */
- (void)retrieveObjectWithHandler:(NTNetworkRetrieveObject)handler atPath:(NSString *)path;

/**
 *  Call to retrieve collection of items. Must be array.
 */
- (void)retrieveCollectionWithHandler:(NTNetworkRetrieveCollection)handler atPath:(NSString *)path;

/**
 *  Call to retrieve dictionary object.
 */
- (void)retrieveDictionaryWithHandler:(NTNetworkRetrieveDictionary)handler atPath:(NSString *)path;

@end

/**
 *  Common class for all data collectors.
 */
@interface NTDataCollector : NSObject
+ (instancetype)sharedInstance;

/**
 *  Call to retrieve an image from url path
 */
- (void)retrieveImageFromURLWithHandler:(NTNetworkRetrieveImage)handler atPath:(NSString *)path;
@end

/**
 *  A class that receive json response from network.
 */
@interface NTJSONNetworkCollector : NTDataCollector<NTDataCollectorProtocol>
@end

/**
 *  A class that receive json response from local storage
 */
@interface NTJSONLocalCollector : NTDataCollector<NTDataCollectorProtocol>
@end
