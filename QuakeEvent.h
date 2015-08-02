//
//  QuakeEvent.h
//  
//
//  Created by Scott Ferwerda on 8/2/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QuakeEvent : NSManagedObject

@property (nonatomic, retain) NSString * usgsId;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * depth;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * magnitude;

@end
