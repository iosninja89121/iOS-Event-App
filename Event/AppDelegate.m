//
//  AppDelegate.m
//  Event
//
//  Created by Admin on 21/11/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import "DataModel/DataModel.h"
#import "HomeViewController.h"
#import "ViewController.h"
#import <AudioToolbox/AudioServices.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

NSInteger lastRead = -1;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    //TODO get lastread from settings
    if (lastRead == -1 && [[NSUserDefaults standardUserDefaults] objectForKey:@"LastReadItemId"]) {
        lastRead = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastReadItemId"];
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    self.strMajorMinor = [userDefault objectForKey:@"BeaconMajorMinor"];
    
    if(self.strMajorMinor == nil || [self.strMajorMinor isEqualToString:@""]) self.strMajorMinor = @"1001554415";
    self.isAppRunning = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(performBackgroundFetch:) userInfo:nil repeats:YES];
    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];

    if (localNotif) {
        self.strMajorMinor = [localNotif.userInfo objectForKey:@"stringMajorMinor"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        HomeViewController *vcHome = (HomeViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        ViewController *vcList = (ViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        
        UINavigationController *navCtrl = [[UINavigationController alloc] init];
        navCtrl.viewControllers = @[vcHome, vcList];
        [navCtrl setNavigationBarHidden:YES];
        
        self.window.rootViewController = navCtrl;
        application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
        
        [self performSelector:@selector(fireManualNotification) withObject:self afterDelay:10.0 ];
        
    }
    
//    self.strMajorMinor = @"1001554415";
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    return YES;
}

- (void)fireManualNotification{
//    appDelegate.strMajorMinor = @"1001554415";
    [[NSNotificationCenter defaultCenter] postNotificationName:NotifyFindBeekers object:nil];
}


-(void)performBackgroundFetch: (NSTimer*) timer {
    [self application:[UIApplication sharedApplication] performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {
        NSLog(@"fetch performed at open with timer");
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Tell location manager to stop monitoring for the beacon region
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
    
    // Tell location manager to stop ranging for the beacon region
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"" forKey:@"BeaconMajorMinor"];
    [userDefault setBool:YES forKey:@"isAppInBackground"];
    [userDefault setInteger:0 forKey:@"TotalBeacons"];
    application.applicationIconBadgeNumber = 0;
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self application:[UIApplication sharedApplication] performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {
        NSLog(@"fetch performed at open");
        application.applicationIconBadgeNumber = 0;
    }];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:NO forKey:@"isAppInBackground"];
    [userDefault setInteger:0 forKey:@"TotalBeacons"];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if(self.isAppRunning){
        NSLog(@"fetch performing at the foreground, so background mode has been cancelled at this time");
        return;
    }
    
    NSLog(@"fetch performed at background");
    // arvind code
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    self.strMajorMinor = [userDefault objectForKey:@"BeaconMajorMinor"];
    
    if(self.strMajorMinor == nil || [self.strMajorMinor isEqualToString:@""]){
        self.strMajorMinor = @"1001554415";
    }
    
    NSLog(@"userdefault data %@",[userDefault objectForKey:@"BeaconMajorMinor"]);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    NSString *api_link = [NSString stringWithFormat:@"http://ptechpeople.wpengine.com/wp-json/wp/v2/posts?filter[post_status]=publish&filter[posts_per_page]=10&page=%d&filter[category_name]=%@", 1, self.strMajorMinor];
//    NSString *api_link = @"http://ptechpeople.wpengine.com/wp-json/wp/v2/posts?filter[post_status]=publish&filter[posts_per_page]=10&page=1&filter[category_name]=1001554415";

    [manager GET: api_link
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             NSArray *arrResponse = responseObject;
             if (arrResponse.count==0) {
                 [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"LastReadItemId"];
                 
                 return ;
             }
             
             int unread = 0;
             NSInteger lastReadItemId = -1;
             DataModel *lastReadItem;
             for (NSDictionary *item in responseObject) {
                 DataModel *_data = [[DataModel alloc] initWithDict:item];
                 if (_data.item_id == lastRead) {
                     break;
                 } else {
                     if (lastReadItemId < _data.item_id) {
                         lastReadItemId = _data.item_id;
                         lastReadItem = _data;
                     }
                     unread++;
                 }
             }
             
             //unread = 1;
             if (unread == 0) {
                 completionHandler(UIBackgroundFetchResultNoData);
             } else {
                 //send notification
                 if(lastReadItemId != -1) {
                     UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                     localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
                     if (unread > 1) {
                         localNotification.alertBody = [NSString stringWithFormat:@"You have %d unread events", unread ];
                     } else {
                         localNotification.alertBody = lastReadItem.title;
                     }
                     
                     NSDictionary *infoDict = @{@"stringMajorMinor":self.strMajorMinor};
                     localNotification.userInfo = infoDict;
                     
                     localNotification.timeZone = [NSTimeZone defaultTimeZone];
                     [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                     NSLog(@"LocalNotification has been fired");
                 }
                 lastRead = lastReadItemId;
                 [[NSUserDefaults standardUserDefaults] setInteger:lastRead forKey:@"LastReadItemId"];
                 completionHandler(UIBackgroundFetchResultNewData);
                 application.applicationIconBadgeNumber = unread;
                 
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             completionHandler(UIBackgroundFetchResultFailed);
         }];
    
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

@end
