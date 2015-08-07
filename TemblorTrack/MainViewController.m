//
//  ViewController.m
//  TemblorTrack
//
//  Created by Scott Ferwerda on 7/28/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MainViewController.h"

@interface MainViewController ()
{
    QuakeDataManager *quakeManager;
    
    BOOL mapInitialized;
    USGSRect currentMapRect;
}

@property (weak, nonatomic) IBOutlet MKMapView *theMap;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    quakeManager = [[QuakeDataManager alloc] initWithDelegate:self];
    // zoom extents
    currentMapRect = [quakeManager initialRect];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (mapInitialized == NO) {
        double w = currentMapRect.maxLongitude - currentMapRect.minLongitude;
        double h = currentMapRect.maxLatitude - currentMapRect.minLatitude;
        double x0 = currentMapRect.minLongitude + (w / 2.0);
        double y0 = currentMapRect.minLatitude + (h / 2.0);
        CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(y0, x0);
        MKCoordinateSpan mapSpan = MKCoordinateSpanMake(h, w);
        MKCoordinateRegion mapRegion = MKCoordinateRegionMake(centerCoord, mapSpan);
        [self.theMap setRegion:mapRegion animated:YES];
        mapInitialized = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)quakeDataManager:(QuakeDataManager *)quakeDataManager dataUpdated:(NSArray *)quakeData {
    DDLogDebug(@"");
}

@end
