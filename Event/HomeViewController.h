//
//  HomeViewController.h
//  Beeker
//
//  Created by Blue Silver on 1/28/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface HomeViewController : UIViewController<CLLocationManagerDelegate, CBCentralManagerDelegate>{
    AppDelegate *appDelegate;
    CBCentralManager *centralManager;
    
    double latitude;
    double longitude;
}
@end
