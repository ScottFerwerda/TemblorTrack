//
//  QuakeDataManager.h
//  TemblorTrack
//
//  Created by Scott Ferwerda on 8/1/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "USGSDataAPIClient.h"

@class QuakeDataManager;

@interface QuakeDataItem : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *usgsId;
@property (nonatomic, strong) NSDate *dateStarted;
@property (nonatomic, assign) double magnitude;
//@property (nonatomic, assign) double latitude;
//@property (nonatomic, assign) double longitude;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *place;

@end

@protocol QuakeDataManagerDelegate <NSObject>

- (void)quakeDataManager:(QuakeDataManager *)quakeDataManager dataUpdated:(NSArray *)quakeData;

@end

@interface QuakeDataManager : NSObject

@property (weak, nonatomic) id<QuakeDataManagerDelegate> delegate;

- (instancetype)initWithDelegate:(id<QuakeDataManagerDelegate>)delegateIn;
- (USGSRect)initialRect;


@end