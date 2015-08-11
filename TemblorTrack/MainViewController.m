//
//  ViewController.m
//  TemblorTrack
//
//  Created by Scott Ferwerda on 7/28/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MainViewController.h"
#import "QuakeDataOverlay.h"
#import "QuakeDataOverlayRenderer.h"

#define UICOLOR_FROM_RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)/1.0f]

@interface MainViewController ()
{
    QuakeDataManager *quakeManager;
    
    BOOL mapInitialized;
    USGSRect currentMapRect;
    
//    NSMutableArray *viewModel;

    NSMutableArray *currentOverlays;
    NSMutableArray *currentQuakeDataItems;
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
        [quakeManager fetchQuakeDataFromServer];
        mapInitialized = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshTouched:(id)sender {
    [quakeManager fetchQuakeDataFromServer];
}

//- (UIColor *)colorForMagnitude:(double)magnitude {
//    
//}

// heat map color code from http://www.andrewnoske.com/wiki/Code_-_heatmaps_and_color_gradients
void getHeatMapColor(float value, float *red, float *green, float *blue)
{
    const int NUM_COLORS = 4;
    static float color[NUM_COLORS][3] = { {0,0,1}, {0,1,0}, {1,1,0}, {1,0,0} };
    // A static array of 4 colors:  (blue,   green,  yellow,  red) using {r,g,b} for each.
    
    int idx1;        // |-- Our desired color will be between these two indexes in "color".
    int idx2;        // |
    float fractBetween = 0;  // Fraction between "idx1" and "idx2" where our value is.
    
    if(value <= 0)      {  idx1 = idx2 = 0;            }    // accounts for an input <=0
    else if(value >= 1)  {  idx1 = idx2 = NUM_COLORS-1; }    // accounts for an input >=0
    else
    {
        value = value * (NUM_COLORS-1);        // Will multiply value by 3.
        idx1  = floor(value);                  // Our desired color will be after this index.
        idx2  = idx1+1;                        // ... and before this index (inclusive).
        fractBetween = value - (float)idx1;    // Distance between the two indexes (0-1).
    }
    
    *red   = (color[idx2][0] - color[idx1][0])*fractBetween + color[idx1][0];
    *green = (color[idx2][1] - color[idx1][1])*fractBetween + color[idx1][1];
    *blue  = (color[idx2][2] - color[idx1][2])*fractBetween + color[idx1][2];
}

#pragma mark - QuakeDataManagerDelegate

- (void)quakeDataManager:(QuakeDataManager *)quakeDataManager dataUpdated:(NSArray *)quakeData {
//    DDLogDebug(@"");
    [self updateDisplayWithQuakeData:quakeData];
}

- (void)updateDisplayWithQuakeData:(NSArray *)quakeData {
    if (currentQuakeDataItems == nil) {
        currentQuakeDataItems = [[NSMutableArray alloc] init];
    }
    else {
        [currentQuakeDataItems removeAllObjects];
    }
    // remove any existing overlays
    if (currentOverlays == nil) {
        currentOverlays = [[NSMutableArray alloc] init];
    }
    else {
        [self.theMap removeOverlays:currentOverlays];
        [currentOverlays removeAllObjects];
    }
    
    for (QuakeDataItem *qdi in quakeData) {
        [currentQuakeDataItems addObject:qdi];
        
        MKCircle *c = [MKCircle circleWithCenterCoordinate:qdi.coordinate radius:qdi.magnitude * 10000.0]; // circle size dependent on strength of quake: 10km/unit magnitude
        [currentOverlays addObject:c];
    }
    
    [self.theMap addOverlays:currentOverlays];
}

- (QuakeDataItem *)qdiForOverlay:(id <MKOverlay>)overlay {
    QuakeDataItem *result = nil;
    for (NSUInteger i = 0; i < currentOverlays.count; i++) {
        if (currentOverlays[i] == overlay) {
            result = currentQuakeDataItems[i];
            break;
        }
    }
    return result;
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    QuakeDataItem *qdi = [self qdiForOverlay:overlay];
    MKCircle *circ = (MKCircle *)overlay;
    MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:circ];
    float r, g, b;
    // TODO: cap the hottest color at magnitude 8.0 (severe quake)
    float heatValue = MIN(qdi.magnitude / 8.0, 1.0);
    getHeatMapColor(heatValue, &r, &g, &b);
    DDLogDebug(@"Render mag %f quake with heat value %f, RGB=(%f,%f,%f)", qdi.magnitude, (double)heatValue, (double)r, (double)g, (double)g);
    renderer.fillColor = [UIColor colorWithRed:r green:g blue:b alpha:0.50];
    renderer.strokeColor = [UIColor blackColor];
    renderer.lineWidth = 0.1;
    
    return renderer;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers {
    DDLogDebug(@"");
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    DDLogDebug(@"");
}

@end
