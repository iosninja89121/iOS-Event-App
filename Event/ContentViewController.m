//
//  ContentViewController.m
//  Event
//
//  Created by Admin on 03/12/15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "ContentViewController.h"
#import "DataModel.h"

#define WIDTH_OF_SCROLL_PAGE [[UIScreen mainScreen] bounds].size.width
#define HEIGHT_OF_SCROLL_PAGE [[UIScreen mainScreen] bounds].size.height - 68
#define LEFT_EDGE_OFSET 0

@interface ContentViewController ()

@end

@implementation ContentViewController

@synthesize data;
@synthesize index;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [bgPageControl setNumberOfPages:data.count];
    [m_scrollView setContentSize:CGSizeMake(m_scrollView.frame.size.width * data.count, m_scrollView.frame.size.height)];
    
    for (int i = 0; i < data.count; i++) {
        //loop this bit
        DataModel *item = [data objectAtIndex:i];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake((WIDTH_OF_SCROLL_PAGE * i) + LEFT_EDGE_OFSET, 0, WIDTH_OF_SCROLL_PAGE, HEIGHT_OF_SCROLL_PAGE)];
        [webView loadHTMLString:item.content baseURL:nil];
        
        [m_scrollView addSubview:webView];
    }

    [m_scrollView setContentSize:CGSizeMake(WIDTH_OF_SCROLL_PAGE * data.count, HEIGHT_OF_SCROLL_PAGE)];
    [m_scrollView setContentOffset:CGPointMake(0, 0)];
    [m_scrollView scrollRectToVisible:CGRectMake(WIDTH_OF_SCROLL_PAGE * index, 0 , WIDTH_OF_SCROLL_PAGE, HEIGHT_OF_SCROLL_PAGE) animated:NO];

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)actionBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth);
    
    bgPageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    int currentPage = floor((scrollView.contentOffset.x - scrollView.frame.size.width / ([data count])) / scrollView.frame.size.width) + 1;
    if (currentPage==0) {
        //go last but 1 page
        [scrollView scrollRectToVisible:CGRectMake(WIDTH_OF_SCROLL_PAGE * [data count],0,WIDTH_OF_SCROLL_PAGE,HEIGHT_OF_SCROLL_PAGE) animated:NO];
    } else if (currentPage==([data count])) {
        [scrollView scrollRectToVisible:CGRectMake(WIDTH_OF_SCROLL_PAGE,0,WIDTH_OF_SCROLL_PAGE,HEIGHT_OF_SCROLL_PAGE) animated:NO];
    }
}

- (IBAction)changePage:(id)sender {
    NSInteger page = bgPageControl.currentPage;
    CGRect frame = m_scrollView.frame;
    
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [m_scrollView scrollRectToVisible:frame animated:YES];
    
}

@end
