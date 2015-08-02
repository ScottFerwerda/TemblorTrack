//
//  QuakeDataManager.h
//  TemblorTrack
//
//  Created by Scott Ferwerda on 8/1/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "USGSDataAPIClient.h"

@interface QuakeDataManager : NSObject

- (USGSRect)initialRect;

@end
