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
    
//    NSMutableArray *viewModel;

    NSMutableArray *currentOverlays;
    NSMutableArray *currentQuakeDataItems;
    
    BOOL isPlaying;
    NSTimer *playLoopTimer;
}

@property (weak, nonatomic) IBOutlet MKMapView *theMap;
@property (weak, nonatomic) IBOutlet UIView *activityOverlayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *noDataOverlayView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *startTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *endTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    quakeManager = [[QuakeDataManager alloc] initWithDelegate:self];
    // zoom extents
    currentMapRect = [quakeManager initialRect];
    [self hideActivityOverlay];
    [self blankDateButtons];
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
        [self showActivityOverlay];
        [quakeManager fetchQuakeDataFromServer];
        mapInitialized = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetButtonTouched:(id)sender {
    [quakeManager clearManager];
    [self fetchQuakeDataFromServer];
}

- (IBAction)refreshButtonTouched:(id)sender {
    [self fetchQuakeDataFromServer];
}

- (IBAction)timeSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float frac = MIN(1.0, MAX(0.0, slider.value));
    NSTimeInterval timeInterval = [quakeManager.endTime timeIntervalSinceDate:quakeManager.startTime];
    NSTimeInterval fracTimeInterval = frac * timeInterval;
    NSDate *fracDate = [quakeManager.startTime dateByAddingTimeInterval:fracTimeInterval];
    NSArray *fracQuakes = [quakeManager currentQuakeDataFromStartTime:quakeManager.startTime toEndTime:fracDate];
    [self updateDisplayWithQuakeData:fracQuakes];
}

- (IBAction)playButtonTouched:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (isPlaying) {
        [playLoopTimer invalidate];
        [button setImage:[UIImage imageNamed:@"ionicons_ios7_play"] forState:UIControlStateNormal];
        isPlaying = NO;
    }
    else {
        [button setImage:[UIImage imageNamed:@"ionicons_ios7_pause"] forState:UIControlStateNormal];
        float startFrac = self.timeSlider.value;
        if (startFrac >= 0.99) {
            startFrac = 0.0;
            self.timeSlider.value = startFrac;
        }
        isPlaying = YES;
        playLoopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/5.0 target:self selector:@selector(playTimerFired:) userInfo:nil repeats:YES];
    }
}

- (void)playTimerFired:(NSTimer *)timer {
    UISlider *slider = self.timeSlider;
    float frac = MIN(1.0, MAX(0.0, slider.value));
    NSTimeInterval timeInterval = [quakeManager.endTime timeIntervalSinceDate:quakeManager.startTime];
    NSTimeInterval fracTimeInterval = frac * timeInterval;
    NSDate *fracDate = [quakeManager.startTime dateByAddingTimeInterval:fracTimeInterval];
    NSArray *fracQuakes = [quakeManager currentQuakeDataFromStartTime:quakeManager.startTime toEndTime:fracDate];
    [self updateDisplayWithQuakeData:fracQuakes];
    
    if (frac >= 0.99) {
        [timer invalidate];
        [self.playButton setImage:[UIImage imageNamed:@"ionicons_ios7_play"] forState:UIControlStateNormal];
        isPlaying = NO;
    }
    else {
        frac = MIN(1.0, frac + 0.02);
        self.timeSlider.value = frac;
    }
}

- (void)showActivityOverlay {
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    [self.activityOverlayView setHidden:NO];
}

- (void)hideActivityOverlay {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    [self.activityOverlayView setHidden:YES];
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
    
    if (isPlaying == YES || self.timeSlider.value <= 0.99 || quakeData.count > 0) {
        self.noDataOverlayView.hidden = YES;
        for (QuakeDataItem *qdi in quakeData) {
            [currentQuakeDataItems addObject:qdi];
            
            MKCircle *c = [MKCircle circleWithCenterCoordinate:qdi.coordinate radius:qdi.magnitude * 10000.0]; // circle size dependent on strength of quake: 10km/unit magnitude
            [currentOverlays addObject:c];
        }
        [self.theMap addOverlays:currentOverlays];
    }
    else {
        self.noDataOverlayView.hidden = NO;
    }
}

- (void)blankDateButtons {
    [self.startTimeButton setTitle:@" " forState:UIControlStateNormal];
    [self.endTimeButton setTitle:@" " forState:UIControlStateNormal];
}

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueStartDateToDatePicker"] ||
        [segue.identifier isEqualToString:@"SegueEndDateToDatePicker"]) {
        QuakeDatesPickerViewController *pickerVC = segue.destinationViewController;
        pickerVC.delegate = self;
        pickerVC.startDate = quakeManager.startTime;
        pickerVC.endDate = quakeManager.endTime;
    }
}

#pragma mark - QuakeDatesPickerDelegate

- (void)quakeDatePickingCompletedWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    // fetch new data
    [self showActivityOverlay];
    [quakeManager fetchQuakeDataFromServerWithStartTime:startDate andEndTime:endDate];
}

#pragma mark - QuakeDataManagerDelegate

- (void)quakeDataManager:(QuakeDataManager *)quakeDataManager dataUpdated:(NSArray *)quakeData {
    
//    // debug
//    {
//        DDLogDebug(@"x");
//        NSArray *someQuakes = [quakeDataManager currentQuakeDataFromStartTime:quakeDataManager.startTime toEndTime:quakeDataManager.endTime];
//        DDLogDebug(@"y");
//        DDLogDebug(@"subset count=%zd", someQuakes.count);
//    }
    
    
    [self hideActivityOverlay];
    
    // update the date buttons
    [self.startTimeButton setTitle:[self dateButtonTitleFromDate:quakeDataManager.startTime] forState:UIControlStateNormal];
    [self.endTimeButton setTitle:[self dateButtonTitleFromDate:quakeDataManager.endTime] forState:UIControlStateNormal];
    
    // update the map display
    [self updateDisplayWithQuakeData:quakeData];
}

- (void)quakeDataManager:(QuakeDataManager *)quakeDataManager dataFailedToUpdate:(NSError *)error {
    [self hideActivityOverlay];
    NSString *errMsg = nil;
    if (error != nil) {
        errMsg = [NSString stringWithFormat:@"Error retrieving earthquake data from the USGS servers.\n\n%@\n\n(Code %zd)", error.localizedDescription, error.code];
    }
    else {
        errMsg = @"Oops! Something went wrong.";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //
    }];
    [alert addAction:cancelAction];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self fetchQuakeDataFromServer];
    }];
    [alert addAction:retryAction];
    
    [self presentViewController:alert animated:YES completion:^{
        //
    }];
}

- (void)fetchQuakeDataFromServer {
    [self showActivityOverlay];
    if (quakeManager.startTime == nil || quakeManager.endTime == nil) {
        [quakeManager fetchQuakeDataFromServer];
    }
    else {
        [quakeManager fetchQuakeDataFromServerWithStartTime:quakeManager.startTime andEndTime:quakeManager.endTime];
    }
}

- (NSString *)dateButtonTitleFromDate:(NSDate *)aDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    return [dateFormatter stringFromDate:aDate];
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
    // cap the hottest color at magnitude 8.0 (severe quake)
    float heatValue = MIN(qdi.magnitude / 8.0, 1.0);
    getHeatMapColor(heatValue, &r, &g, &b);
//    DDLogDebug(@"Render mag %f quake with heat value %f, RGB=(%f,%f,%f)", qdi.magnitude, (double)heatValue, (double)r, (double)g, (double)g);
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
