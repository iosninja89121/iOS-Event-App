//
//  ViewController.h
//  Event
//
//  Created by Admin on 21/11/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : CustomViewController<UITableViewDataSource, UITableViewDelegate> {
    
    AppDelegate *appDelegate;
   // CLLocationManager *locationManager;
    
    NSMutableArray                  *arrData;
    
    IBOutlet UITableView *listView;

    BOOL bPossibleLoadNext;
    int refresh;
}

//@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;

@end

