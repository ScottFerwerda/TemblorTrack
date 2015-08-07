//
//  QuakeDataManager.m
//  TemblorTrack
//
//  Created by Scott Ferwerda on 8/1/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import "QuakeDataManager.h"

@implementation QuakeDataItem

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"QuakeDataItem: date=%@, magnitude=%f, lat/long=(%f,%f), place=%@, USGSID=%@", self.dateStarted, self.magnitude, self.latitude, self.longitude, self.place, self.usgsId];
}

@end

@interface QuakeDataManager ()
{
    NSURLSessionDataTask *dataTask;
}

@end

@implementation QuakeDataManager

- (USGSRect)initialRect {
    USGSRect rect;
    rect.minLongitude = -124.848974;
    rect.minLatitude  =  24.396308;
    rect.maxLongitude = -66.885444;
    rect.maxLatitude  =  49.384358;
    return rect;
}

- (instancetype)initWithDelegate:(id<QuakeDataManagerDelegate>)delegateIn
{
    self = [super init];
    if (self) {
        self.delegate = delegateIn;
        NSDate *endTime = [NSDate date];
        NSDate *startTime = [NSDate dateWithTimeInterval:-(60.0 * 60.0 * 24.0 * 15.0) sinceDate:endTime];
        dataTask = [[USGSDataAPIClient sharedClient] fetchQuakeDataForRect:[self initialRect] withStartTime:startTime andEndTime:endTime success:^(NSURLSessionDataTask *sessionDataTask, id responseObject) {
            // extract "features" json list
            NSArray *jsonFeatures = ((NSDictionary *)responseObject)[@"features"];
            NSMutableArray *newQuakeDataItems = [[NSMutableArray alloc] initWithCapacity:jsonFeatures.count];
            for (NSDictionary *aJsonFeature in jsonFeatures) {
                QuakeDataItem *qdi = [[QuakeDataItem alloc] init];
                qdi.usgsId = aJsonFeature[@"id"];
                NSDictionary *jsonGeometry = aJsonFeature[@"geometry"];
                NSString *jsonGeomType = jsonGeometry[@"type"];
                NSAssert([jsonGeomType isEqualToString:@"Point"], @"unexpected coordinate type in data");
                NSArray *jsonCoord = jsonGeometry[@"coordinates"];
//                double longitude = ((NSNumber *)(jsonCoord[0])).doubleValue;
//                double latitude = ((NSNumber *)(jsonCoord[1])).doubleValue;
                qdi.longitude = ((NSNumber *)(jsonCoord[0])).doubleValue;
                qdi.latitude = ((NSNumber *)(jsonCoord[1])).doubleValue;
                NSDictionary *jsonProps = aJsonFeature[@"properties"];
//                double magnitude = ((NSNumber *)(jsonProps[@"mag"])).doubleValue;
                qdi.magnitude = ((NSNumber *)(jsonProps[@"mag"])).doubleValue;
//                NSString *place = jsonProps[@"place"];
                qdi.place = jsonProps[@"place"];
                double rawtime = ((NSNumber *)(jsonProps[@"time"])).doubleValue;
                // timestamp is in ms since epoch (1/1/1970) convert it
//                NSDate *date = [NSDate dateWithTimeIntervalSince1970:(rawtime/1000)];
                qdi.dateStarted = [NSDate dateWithTimeIntervalSince1970:(rawtime/1000)];
//                DDLogDebug(@"%@: Magnitude %f quake at (%f, %f), %@ (ID: %@)", date, magnitude, longitude, latitude, place, usgsId);
                DDLogDebug(@"%@: Magnitude %f quake at (%f, %f), %@ (ID: %@)", qdi.dateStarted, qdi.magnitude, qdi.latitude, qdi.longitude, qdi.place, qdi.usgsId);
                [newQuakeDataItems addObject:qdi];
            }
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(quakeDataManager:dataUpdated:)]) {
                [self.delegate quakeDataManager:self dataUpdated:newQuakeDataItems];
            }
        } failure:^(NSURLSessionDataTask *sessionDataTask, NSError *error) {
            //
            DDLogDebug(@"");
        }];

    }
    return self;
}

@end
