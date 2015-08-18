//
//  USGSDataAPIClient.m
//  TemblorTrack
//
//  Created by Scott Ferwerda on 8/1/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import "USGSDataAPIClient.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>


@implementation USGSDataAPIClient

static NSString * const USGSDataAPIBaseURLString = @"http://ehp2-earthquake.wr.usgs.gov/fdsnws/event/1/";

+ (instancetype)sharedClient {
    static USGSDataAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:USGSDataAPIBaseURLString]];
    });
    return _sharedClient;
}

- (NSURLSessionDataTask *)fetchQuakeDataForRect:(USGSRect)rect withStartTime:(NSDate *)startTime andEndTime:(NSDate *)endTime success:(void (^)(NSURLSessionDataTask *, id))successBlock failure:(void (^)(NSURLSessionDataTask *, NSError *))failureBlock {
    // we can't wait forever
    [self.requestSerializer setTimeoutInterval:20.0];
    /*
     query?format=geojson&eventtype=earthquake&starttime=2015-07-20&latitude=35&longitude=-78&maxradiuskm=3000
     */
    NSString *queryUrl = [[NSURL URLWithString:@"query" relativeToURL:self.baseURL] absoluteString];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"format"] = @"geojson";
    params[@"eventtype"] = @"earthquake";
    params[@"minmagnitude"] = @(2.5);
    params[@"minlatitude"] = @(rect.minLatitude);
    params[@"minlongitude"] = @(rect.minLongitude);
    params[@"maxlatitude"] = @(rect.maxLatitude);
    params[@"maxlongitude"] = @(rect.maxLongitude);
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    if (startTime != nil) {
        params[@"starttime"] = [dateFormatter stringFromDate:startTime];
    }
    if (endTime != nil) {
        params[@"endtime"] = [dateFormatter stringFromDate:endTime];
    }
    params[@"orderby"] = @"time-asc";
    
    DDLogDebug(@"performing HTTP GET request to %@ with parameters %@", queryUrl, params);
    return [self GET:queryUrl parameters:params success:successBlock failure:failureBlock];
}

@end
