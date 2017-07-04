//
//  ViewController.m
//  MagneticTest
//
//  Created by Andrew Simmons on 6/21/17.
//  Copyright © 2017 medl. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
#import "Sample.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

@interface ViewController ()
{
    CLLocationManager *locationManagerPassanger;
    CLLocationManager *locationManagerDriver;
    CLBeaconRegion *passangerBeaconRegion;
    CLBeaconRegion *driverBeaconRegion;
    
    NSInteger driverRange;
    NSInteger passangerRange;
    NSInteger driverSnapShots;
    NSInteger passangerSnapShots;

    __weak IBOutlet UILabel *driverBeaconLabel;
    __weak IBOutlet UILabel *passangerBeaconLabel;
    __weak IBOutlet UIButton *stopBtn;
    __weak IBOutlet UIButton *startBtn;
}
@end


static NSString *beaconIdentifier = @"com.medlmobile.cfz";
static NSString *uuidDriver = @"048039B2-B8E1-11E4-97AC-F2D68ED530EF";
static NSString *uuidPassanger = @"048039B2-B8E1-11E4-97AC-F2D68ED529EF";

int getUptimeInMilliseconds()
{
    const int64_t oneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info;

    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }

    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    return (int)((mach_absolute_time() * s_timebase_info.numer) / (oneMillion * s_timebase_info.denom));
}


@implementation ViewController
{
    CMMotionManager *_motionManager;
    CLLocationManager *_locationManager;
    int _startTime;
    NSMutableArray <Sample *> *_accelerationSamples;
    BOOL _takeDriverSnapshot;
    BOOL _takePassangerSnapshot;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)startTapped:(id)sender {
    _startTime = getUptimeInMilliseconds();
    
    // Regardless of whether the device is a transmitter or receiver, we need a beacon region.
    NSUUID *uid = [[NSUUID alloc] initWithUUIDString:uuidDriver];
    driverBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uid major:5 minor:2 identifier:beaconIdentifier];
    
    // When set to YES, the location manager sends beacon notifications when the user turns on the display and the device is already inside the region.
    [driverBeaconRegion setNotifyEntryStateOnDisplay:YES];
    [driverBeaconRegion setNotifyOnEntry:YES];
    [driverBeaconRegion setNotifyOnExit:YES];
    
    driverBeaconRegion.notifyEntryStateOnDisplay = YES;
    
    NSUUID *uid2 = [[NSUUID alloc] initWithUUIDString:uuidPassanger];
    passangerBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uid2 major:5 minor:2 identifier:beaconIdentifier];
    
    // When set to YES, the location manager sends beacon notifications when the user turns on the display and the device is already inside the region.
    [passangerBeaconRegion setNotifyEntryStateOnDisplay:YES];
    [passangerBeaconRegion setNotifyOnEntry:YES];
    [passangerBeaconRegion setNotifyOnExit:YES];
    
    passangerBeaconRegion.notifyEntryStateOnDisplay = YES;
    
    locationManagerDriver = [[CLLocationManager alloc] init];
    [locationManagerDriver startMonitoringForRegion:driverBeaconRegion];
    [locationManagerDriver startRangingBeaconsInRegion:driverBeaconRegion];
    
    locationManagerPassanger = [[CLLocationManager alloc] init];
    [locationManagerPassanger startMonitoringForRegion:passangerBeaconRegion];
    [locationManagerPassanger startRangingBeaconsInRegion:passangerBeaconRegion];
}

- (IBAction)stopTapped:(id)sender {
    driverSnapShots = 0;
    passangerRange = 0;
    _takeDriverSnapshot = true;
    _takePassangerSnapshot = true;
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    
    for (CLBeacon *beacon in beacons) {
    
        if ([[beacon.proximityUUID UUIDString] compare: uuidDriver]) {
            
            driverRange = beacon.rssi;
            driverBeaconLabel.text = [NSString stringWithFormat:@"%ld", (long)driverRange];
            if (_takeDriverSnapshot) {
                driverSnapShots += 1;
                //add reading to printout
                if (driverSnapShots == 100) {
                    _takeDriverSnapshot = false;
                }
            }
        } else {
            passangerRange = beacon.rssi;
            passangerBeaconLabel.text = [NSString stringWithFormat:@"%ld", (long)passangerRange];
            if (_takePassangerSnapshot) {
                driverSnapShots += 1;
                //add reading to printout
                if (passangerSnapShots == 100) {
                    _takePassangerSnapshot = false;
                }
            }
        }
        
    }
}

- (IBAction)onPrintdriver:(UIButton *)sender {
}
 
- (IBAction)onPrintPassanger:(UIButton *)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
