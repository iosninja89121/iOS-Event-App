//
//  CustomViewController.h
//
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomViewController : UIViewController

-(void)setModeLoading:(BOOL)active withText:(NSString *)text;
-(void)startModeLoadingWithText:(NSString *)text;
-(void)stopModeLoading;
-(BOOL)isLoading;

@end
