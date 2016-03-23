//
//  NewContentViewController.m
//  Beeker
//
//  Created by Blue Silver on 1/28/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NewContentViewController.h"

@interface NewContentViewController ()
@property (weak, nonatomic) IBOutlet AsyncImageView *imgvPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubText;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation NewContentViewController
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DataModel *data = [self.data objectAtIndex:self.index];
    
    if ([data.feature_image_url isEqualToString:@""] ) {
        _imgvPhoto.image = [UIImage imageNamed:@"bg_photo"];
    } else {
        _imgvPhoto.imageURL = [NSURL URLWithString:data.feature_image_url];
    }
    
    _imgvPhoto.layer.masksToBounds = YES;
    _imgvPhoto.layer.borderWidth = 2.0;
    _imgvPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    _imgvPhoto.layer.cornerRadius = _imgvPhoto.frame.size.height / 2;
    
    _lblTitle.text = data.title;
    
    NSString *content = data.excerpt;
    content = [content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:content];
    [attrStr1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, content.length)];
    
    _lblSubText.text = content;
    
    [_webView loadHTMLString:data.content baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
