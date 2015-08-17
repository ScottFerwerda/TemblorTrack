//
//  DatesPickerViewController.h
//  TemblorTrack
//
//  Created by Scott Ferwerda on 8/17/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuakeDatesPickerDelegate <NSObject>

@required
- (void)quakeDatePickingCompletedWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

@end

@interface QuakeDatesPickerViewController : UIViewController

@property IBInspectable BOOL isEndDatePicker;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (weak, nonatomic) id<QuakeDatesPickerDelegate> delegate;

@end
