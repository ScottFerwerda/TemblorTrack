//
//  DatesPickerViewController.m
//  TemblorTrack
//
//  Created by Scott Ferwerda on 8/17/15.
//  Copyright (c) 2015 Scott Ferwerda. All rights reserved.
//

#import "QuakeDatesPickerViewController.h"

@interface QuakeDatesPickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation QuakeDatesPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isEndDatePicker) {
        self.datePicker.date = self.endDate;
    }
    else {
        self.datePicker.date = self.startDate;
    }
    
    // can't get data from the future
    self.datePicker.maximumDate = [NSDate date];
    if (self.isEndDatePicker) {
        self.datePicker.minimumDate = self.startDate;
    }
    else {
        // only 31 days info available
        self.datePicker.minimumDate = [self.datePicker.maximumDate dateByAddingTimeInterval:-(60.0 * 60.0 * 24.0 * 31.0)];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)doneButtonTouched:(id)sender {
    self.endDate = self.datePicker.date;
    if ([self.delegate respondsToSelector:@selector(quakeDatePickingCompletedWithStartDate:andEndDate:)]) {
        [self.delegate quakeDatePickingCompletedWithStartDate:self.startDate andEndDate:self.endDate];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueStartDatePickerToEndDatePicker"]) {
        self.startDate = self.datePicker.date;
        QuakeDatesPickerViewController *endDatePickerVC = segue.destinationViewController;
        endDatePickerVC.delegate = self.delegate;
        endDatePickerVC.startDate = self.startDate;
        endDatePickerVC.endDate = self.endDate;
    }
}
@end
