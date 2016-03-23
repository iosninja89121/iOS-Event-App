//
//  AppDelegate.h
//  Event
//
//  Created by Admin on 21/11/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (strong, nonatomic)CLLocationManager *locationManager;

@property (nonatomic , strong) NSString *strMajorMinor;
@property (nonatomic) BOOL isAppRunning;
@end

