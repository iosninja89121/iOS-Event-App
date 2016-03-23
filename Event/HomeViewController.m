//
//  HomeViewController.m
//  Beeker
//
//  Created by Blue Silver on 1/28/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "HomeViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface HomeViewController ()
@property (nonatomic , strong) NSString *strMajorMinor;// arvind code
@property (nonatomic) BOOL isClicked;
@end

NSString *major;
NSString *minor;
UIBackgroundTaskIdentifier _backgroundTask;

@implementation HomeViewController

- (IBAction)onSeek:(id)sender {
//    if(appDelegate.strMajorMinor == nil || [appDelegate.strMajorMinor isEqualToString:@""]){
//        UIAlertController * alert=[UIAlertController
//                                   alertControllerWithTitle:@"No Beeker found. pls wait"
//                                   message:nil
//                                   preferredStyle:UIAlertControllerStyleAlert];
//        
//        [self presentViewController:alert animated:YES completion:nil];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [alert dismissViewControllerAnimated:YES completion:nil];
//            
//        });
//        
//        return;
//    }
    self.isClicked = YES;
    [self centralManagerDidUpdateState:centralManager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.locationManager = [[CLLocationManager alloc] init];
    appDelegate.locationManager.delegate = self;
    appDelegate.locationManager.distanceFilter = kCLDistanceFilterNone;
    appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [appDelegate.locationManager startMonitoringSignificantLocationChanges];
    [appDelegate.locationManager requestAlwaysAuthorization];
    
    // Create a NSUUID with the same UUID as the broadcasting beacon
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"];// PLz change this id with actual beacon device ID.
    
    // Setup a new region with that UUID and same identifier as the broadcasting beacon
    appDelegate.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                    identifier:@"com.appcoda.testregion"];
    
    
//     Check if beacon monitoring is available for this device
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        
        UIAlertController * alert=[UIAlertController
                                   alertControllerWithTitle:@"Monitoring not available"
                                   message:nil
                                   preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    self.isClicked = NO;
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    // Tell location manager to start monitoring for the beacon region
    [appDelegate.locationManager startMonitoringForRegion:appDelegate.myBeaconRegion];
    
    // Tell location manager to start ranging for the beacon region
    [appDelegate.locationManager startRangingBeaconsInRegion:appDelegate.myBeaconRegion];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma Location Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [errorAlert show];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != Nil) {
        appDelegate.latitude = newLocation.coordinate.latitude;
        appDelegate.latitude = newLocation.coordinate.longitude;
    }
    
    [manager stopUpdatingLocation];
}

// Below code written by arvind
#pragma mark - Checking Bluetooth status

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        //Do what you intend to do
        if(self.isClicked){
            UIViewController *vcTable = (UIViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
            [self.navigationController pushViewController:vcTable animated:YES];
            
            self.isClicked = NO;
        }
        
    } else if(central.state == CBCentralManagerStatePoweredOff) {
        //Bluetooth is disabled. ios pops-up an alert automatically
        // [self AlertWithCancel_btn:@"Please turn on bluetooth to connect Beacon."];
        if(self.isClicked){
            UIAlertController * alert=[UIAlertController
                                       alertControllerWithTitle:@"Please turn on the bluetooth."
                                       message:nil
                                       preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
            
            self.isClicked = NO;
        }
    }
}

#pragma mark - Beacon Methods

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if ([userDefault boolForKey:@"isAppInBackground"]) {
        [self extendBackgroundRunningTime];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self extendBackgroundRunningTime];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:YES forKey:@"isAppInBackground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:NO forKey:@"isAppInBackground"];
    
}

- (void)extendBackgroundRunningTime {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:YES forKey:@"isAppInBackground"];
    
    if (_backgroundTask != UIBackgroundTaskInvalid) {
        // if we are in here, that means the background task is already running.
        // don't restart it.
        return;
    }
    NSLog(@"Attempting to extend background running time");
    
    __block Boolean self_terminate = YES;
    
    _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"DummyTask" expirationHandler:^{
        NSLog(@"Background task expired by iOS");
        if (self_terminate) {
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
            _backgroundTask = UIBackgroundTaskInvalid;
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Background task started");
        
        while (true) {
            // NSLog(@"background time remaining: %8.2f", [UIApplication sharedApplication].backgroundTimeRemaining);
            [NSThread sleepForTimeInterval:1];
        }
        
    });
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region
{
    // We entered a region, now start looking for our target beacons!
    NSLog(@"Finding beacons.") ;
    
    [appDelegate.locationManager startRangingBeaconsInRegion:appDelegate.myBeaconRegion];
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion *)region
{
    // Exited the region
    NSLog(@"None found.") ;
    // [locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    
}

-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    NSString *uuid;
    // Beacon found!
    // self.strMajorMinor = @"null";//nil;
    
    CLBeacon *foundBeacon = [beacons firstObject];
    if (foundBeacon != nil) {
        
        // self.strMajorMinor = @"";//nil;
        //     You can retrieve the beacon data from its properties
        
        major = [NSString stringWithFormat:@"%@", foundBeacon.major];
        minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
        
        if ([appDelegate.strMajorMinor isEqualToString:@"null"]) {
            appDelegate.strMajorMinor = @"";
        }
        
        appDelegate.strMajorMinor = @"";
        
        for (CLBeacon *beacon in beacons) {
            
            if (![appDelegate.strMajorMinor containsString:[NSString stringWithFormat:@"%@%@",beacon.major,beacon.minor]]) {
                appDelegate.strMajorMinor = [appDelegate.strMajorMinor stringByAppendingFormat:@"%@%@,",beacon.major,beacon.minor];
            }
            
        }
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        if ([userDefault boolForKey:@"isAppInBackground"]) {
            [self startBeaconSearchInBackground:beacons.count];
        }
        
        NSLog(@"strMajorMinor %@",appDelegate.strMajorMinor);
        [userDefault setObject:appDelegate.strMajorMinor forKey:@"BeaconMajorMinor"];
        
        // Tell location manager to stop monitoring for the beacon region
        [appDelegate.locationManager stopMonitoringForRegion:appDelegate.myBeaconRegion];
        // Tell location manager to stop ranging for the beacon region
        [appDelegate.locationManager stopRangingBeaconsInRegion:appDelegate.myBeaconRegion];
        
        uuid = foundBeacon.proximityUUID.UUIDString;
        //        NSLog(@"uuid : %@", uuid );
        //        NSLog(@"major : %@", major );
        //        NSLog(@"minor : %@", minor );
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotifyFindBeekers object:nil];
        
    }else{
        appDelegate.strMajorMinor = @"1001554415";//@"";
        // [self getDataRequest]; 1001554415
        
        // Tell location manager to stop monitoring for the beacon region
        [appDelegate.locationManager stopMonitoringForRegion:appDelegate.myBeaconRegion];
        // Tell location manager to stop ranging for the beacon region
        [appDelegate.locationManager stopRangingBeaconsInRegion:appDelegate.myBeaconRegion];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotifyNoFindBeekers object:nil];
        
//        UIAlertController * alert=[UIAlertController
//                                   alertControllerWithTitle:@"No Beeker found."
//                                   message:nil
//                                   preferredStyle:UIAlertControllerStyleAlert];
//        
//        [self presentViewController:alert animated:YES completion:nil];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [alert dismissViewControllerAnimated:YES completion:nil];
//            
//            // Tell location manager to start monitoring for the beacon region
//            [appDelegate.locationManager startMonitoringForRegion:appDelegate.myBeaconRegion];
//            
//            // Tell location manager to start ranging for the beacon region
//            [appDelegate.locationManager startRangingBeaconsInRegion:appDelegate.myBeaconRegion];
//        });
    }
    
    
    NSString *proximityStr = @"";
    
    switch (foundBeacon.proximity)
    {
        case CLProximityUnknown:
        {
            proximityStr=@"CLProximityUnknown";
            NSLog(@"CLProximityUnknown");
            
            break;
        }
        case CLProximityImmediate:
        {
            proximityStr=@"CLProximityImmediate";
            
            NSLog(@"CLProximityImmediate");
            
            break;
        }
        case CLProximityNear:
        {
            proximityStr=@"CLProximityNear";
            
            NSLog(@"CLProximityNear");
            
            break;
            
        }
        case CLProximityFar:
        {
            NSLog(@"CLProximityFar");
            
            break;
        }
            
        default:
            break;
            
    }
    
    NSString *strResult = [NSString stringWithFormat:@"Beacon found!\n UUID:%@ \n Major:%@ \nMinor:%@\n Proximity:%@",uuid,major,minor,proximityStr];
    
    NSLog(@"Result %@",strResult) ;
    
}

-(void)startBeaconSearchInBackground:(NSUInteger)totalBeacons{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSLog(@"useddefault %ld",(long)[userDefault integerForKey:@"TotalBeacons"]);
    NSLog(@"badge value %ld",[UIApplication sharedApplication].applicationIconBadgeNumber);
    if ([userDefault integerForKey:@"TotalBeacons"]!=[UIApplication sharedApplication].applicationIconBadgeNumber||[UIApplication sharedApplication].applicationIconBadgeNumber==0) {
        /*
         [userDefault setInteger:totalBeacons forKey:@"TotalBeacons"];
         UILocalNotification *notification = [[UILocalNotification alloc]init];
         [notification setAlertBody:@"New beacon Found"];
         [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
         [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
         [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
         [UIApplication sharedApplication].applicationIconBadgeNumber = totalBeacons;
         */
        
    }
    
}

@end
