//
//  USGSDataAPIClient.h
//  TemblorTrack
//
//  Created by Scott Ferwerda on 8/1/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AFHTTPSessionManager.h"

typedef struct {
    CLLocationDegrees minLatitude;
    CLLocationDegrees minLongitude;
    CLLocationDegrees maxLatitude;
    CLLocationDegrees maxLongitude;
} USGSRect;

@interface USGSDataAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (NSURLSessionDataTask *)fetchQuakeDataForRect:(USGSRect)rect withStartTime:(NSDate *)startTime andEndTime:(NSDate *)endTime success:(void (^)(NSURLSessionDataTask *, id))successBlock failure:(void (^)(NSURLSessionDataTask *, NSError *))failureBlock;

@end
