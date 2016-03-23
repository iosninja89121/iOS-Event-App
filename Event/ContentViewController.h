//
//  ContentViewController.h
//  Event
//
//  Created by Admin on 03/12/15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController<UIScrollViewDelegate> {
    
    IBOutlet UIPageControl *bgPageControl;
    IBOutlet UIScrollView *m_scrollView;
}

@property (nonatomic) int index;
@property (nonatomic, strong) NSMutableArray *data;

- (IBAction)actionBack:(id)sender;
- (IBAction)changePage:(id)sender;

@end
