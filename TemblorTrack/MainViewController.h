//
//  ViewController.h
//  TemblorTrack
//
//  Created by Scott Ferwerda on 7/28/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuakeDataManager.h"
#import "QuakeDatesPickerViewController.h"


@interface MainViewController : UIViewController <MKMapViewDelegate, QuakeDataManagerDelegate, QuakeDatesPickerDelegate>


@end

