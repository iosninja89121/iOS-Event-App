//
//  ViewController.m
//  Event
//
//  Created by Admin on 21/11/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ViewController.h"
#import "NewContentViewController.h"

@interface ViewController ()

// arvind code
@property (nonatomic , strong) AFHTTPRequestOperation *operation;
@end

BOOL isApiCalling;

@implementation ViewController
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    arrData = [[NSMutableArray alloc] init];
    
    __weak ViewController *weakSelf = self;
    // setup pull-to-refresh
    [listView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
//    [self startModeLoadingWithText:@"Finding Beeker.."];
    
//    appDelegate.strMajorMinor = @"1001554415";
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    appDelegate.strMajorMinor = [userDefault objectForKey:@"BeaconMajorMinor"];
//
    isApiCalling = YES;
    refresh = 1;
    bPossibleLoadNext = false;
    isApiCalling = NO;
    
   // Tell location manager to stop monitoring for the beacon region
   [appDelegate.locationManager stopMonitoringForRegion:appDelegate.myBeaconRegion];
    
   // Tell location manager to stop ranging for the beacon region
  [appDelegate.locationManager stopRangingBeaconsInRegion:appDelegate.myBeaconRegion];
    
    // Tell location manager to start monitoring for the beacon region
    [appDelegate.locationManager startMonitoringForRegion:appDelegate.myBeaconRegion];
    
    // Tell location manager to start ranging for the beacon region
    [appDelegate.locationManager startRangingBeaconsInRegion:appDelegate.myBeaconRegion];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(findBeekers)
                                                 name:NotifyFindBeekers
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noFindBeekers) name:NotifyNoFindBeekers object:nil];
    
    [self startModeLoadingWithText:@"Finding Beeker.."];
    
//    [self performSelector:@selector(fireManualNotification) withObject:self afterDelay:10.0 ];
    
//    [self getDataRequest];
}

- (void)fireManualNotification{
    appDelegate.strMajorMinor = @"1001554415";
    [[NSNotificationCenter defaultCenter] postNotificationName:NotifyFindBeekers object:nil];
}

- (void)findBeekers{
    [self stopModeLoading];
    [self getDataRequest];
}

- (void)noFindBeekers{
    [self stopModeLoading];
    
            UIAlertController * alert=[UIAlertController
                                       alertControllerWithTitle:@"No Beeker found."
                                       message:nil
                                       preferredStyle:UIAlertControllerStyleAlert];
    
            [self presentViewController:alert animated:YES completion:nil];
    
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
    
                [self onBack:nil];
            });

}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    arrData = [[NSMutableArray alloc] init];
    
    refresh = 1;
    bPossibleLoadNext = false;
    //[self startModeLoadingWithText:@"Loading.."];
    
    if (isApiCalling) {
        return;
    }
    [self getDataRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)setGUI {
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    
//    if (m_bOn) {
//        [arrData removeAllObjects];
//        [listView reloadData];
//        
//        [userDefault setObject:@"null" forKey:@"BeaconMajorMinor"];
//        m_bOn = false;
//        
//        [self stopModeLoading];
//        
//        if(repeatScanNum == 0){
//            repeatScanNum = 1;
//            [self setGUI];
//        }else{
//            repeatScanNum = 0;
//        }
//    } else {
//        refresh =1;
//        
//        if (![self.strMajorMinor isEqualToString:@"null"]) {
//            [userDefault setObject:self.strMajorMinor forKey:@"BeaconMajorMinor"];
//        }
//        // NSLog(@"major %@",[userDefault objectForKey:@"BeaconMajorMinor"]);
//        m_bOn = true;
//        
//        [[UserDefaultHelper sharedObject] setStatus:@"on"];
//        
//        [self startModeLoadingWithText:@"Loading.."];
////        if (isApiCalling) {
////            return;
////        }
//        [self getDataRequest];
////        
//        // Tell location manager to start monitoring for the beacon region
//        [appDelegate.locationManager startMonitoringForRegion:appDelegate.myBeaconRegion];
//        
//        // Tell location manager to start ranging for the beacon region
//        [appDelegate.locationManager startRangingBeaconsInRegion:appDelegate.myBeaconRegion];
//        
//    }
//}

- (void) loadBelowMore
{
    if (bPossibleLoadNext) {
//        [self startModeLoadingWithText:@"Loading.."];
        if (isApiCalling) {
            return;
        }
        [self getDataRequest];
    }
    else {
        [listView.infiniteScrollingView stopAnimating];
    }
}

-(void)getDataRequest {
    
    if ([self.operation isExecuting]) {
        return;
    }
    
    if([appDelegate.strMajorMinor isEqualToString:@"null"]) appDelegate.strMajorMinor = @"";
    
    if (appDelegate.strMajorMinor.length>0 && [appDelegate.strMajorMinor hasSuffix:@","]) {
       appDelegate.strMajorMinor= [appDelegate.strMajorMinor substringToIndex:[appDelegate.strMajorMinor length] - 1];
    }
    
    if([appDelegate.strMajorMinor isEqualToString:@""]) appDelegate.strMajorMinor = @"1001554415";
    
    [self startModeLoadingWithText:@"Loading.."];
    
    appDelegate.isAppRunning = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    NSString *api_link = [NSString stringWithFormat:@"http://ptechpeople.wpengine.com/wp-json/wp/v2/posts?filter[post_status]=publish&filter[posts_per_page]=10&page=%d&filter[category_name]=%@", refresh,appDelegate.strMajorMinor];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:api_link]];
    
    
    self.operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self stopModeLoading];
        appDelegate.isAppRunning = NO;
        
        // self.strMajorMinor = @"null";
        isApiCalling = NO;
        NSArray *arrResponse = responseObject;
        
        if (arrResponse.count==0) {
            if(refresh > 1){
                [listView.infiniteScrollingView stopAnimating];
                [self stopModeLoading];
            }else{
                NSLog(@"No data found");
                
                UIAlertController * alert=[UIAlertController
                                           alertControllerWithTitle:@"No beeks found, please try again."
                                           message:nil
                                           preferredStyle:UIAlertControllerStyleAlert];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
                [arrData removeAllObjects];
                [listView reloadData];
            }
            
            
        }else{
            // self.strMajorMinor = @"null";//nil;
            // Tell location manager to stop monitoring for the beacon region
            [appDelegate.locationManager stopMonitoringForRegion:appDelegate.myBeaconRegion];
            // Tell location manager to stop ranging for the beacon region
            [appDelegate.locationManager stopRangingBeaconsInRegion:appDelegate.myBeaconRegion];
            
            NSLog(@"JSON: %@", responseObject);
            // [arrData removeAllObjects];
            
            [listView.infiniteScrollingView stopAnimating];
            [self stopModeLoading];
            
            bPossibleLoadNext = false;
            
            NSMutableArray *arr = (NSMutableArray *)responseObject;
            if (arr.count == 10) {
                bPossibleLoadNext = true;
                refresh++;
            }
            for (NSDictionary *item in responseObject) {
                DataModel *_data = [[DataModel alloc] initWithDict:item];
                
                [arrData addObject:_data];
            }
            
            [self sortMiles];
            [listView reloadData];
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        // isApiCalling = NO;
        NSLog(@"Error: %@", error);
        
        [self stopModeLoading];
        
        [self AlertWithCancel_btn:@"Internet Connection Error!!!"];
        
    }];
    
    
    [self.operation start];
   
    
    /*
    return;
    [manager GET: api_link
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self stopModeLoading];
              
             // self.strMajorMinor = @"null";
              isApiCalling = NO;
              NSArray *arrResponse = responseObject;
              
              if (arrResponse.count==0) {
                   NSLog(@"No data found");
                
                  UIAlertController * alert=[UIAlertController
                   alertControllerWithTitle:@"No events found."
                   message:nil
                   preferredStyle:UIAlertControllerStyleAlert];
                   [self presentViewController:alert animated:YES completion:nil];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                      [alert dismissViewControllerAnimated:YES completion:nil];
                      m_bOn = true;
                      [self setGUI];
                  });
                  m_bOn = true;
                 // [arrData removeAllObjects];
                  [listView reloadData];
              }else{
                   // self.strMajorMinor = @"null";//nil;
                  // Tell location manager to stop monitoring for the beacon region
                  [appDelegate.locationManager stopMonitoringForRegion:appDelegate.myBeaconRegion];
                  // Tell location manager to stop ranging for the beacon region
                  [appDelegate.locationManager stopRangingBeaconsInRegion:appDelegate.myBeaconRegion];

                  NSLog(@"JSON: %@", responseObject);
                 // [arrData removeAllObjects];
                  
                  [listView.infiniteScrollingView stopAnimating];
                  [self stopModeLoading];
                  
                  bPossibleLoadNext = false;
                  
                  NSMutableArray *arr = (NSMutableArray *)responseObject;
                  if (arr.count == 10) {
                      bPossibleLoadNext = true;
                      refresh++;
                  }
                  for (NSDictionary *item in responseObject) {
                      DataModel *_data = [[DataModel alloc] initWithDict:item];
                      
                      [arrData addObject:_data];
                  }
                  
                  [self sortMiles];
                  [listView reloadData];

              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // isApiCalling = NO;
              NSLog(@"Error: %@", error);
              
              [self stopModeLoading];
              
              [self AlertWithCancel_btn:@"Internet Connection Error!!!"];
              
          }];
     */
}

-(void)sortMiles {
    for (int i = 0 ; i < arrData.count - 1; i++) {
        for (int j = i + 1 ; j < arrData.count; j++) {
            DataModel *item = [arrData objectAtIndex:i];
            DataModel *item1 = [arrData objectAtIndex:j];
            float miles = item.miles;
            float miles1 = item1.miles;
            
            if (miles1 < miles) {
                [arrData replaceObjectAtIndex:i withObject:item1];
                [arrData replaceObjectAtIndex:j withObject:item];
            }
        }
    }
}

-(void)AlertWithCancel_btn:(NSString*)AlertMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:AlertMessage message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        alertView.tag = 100;
        [alertView show];
    });
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ListItemCell";
    
    UITableViewCell* cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DataModel *_data = [arrData objectAtIndex:indexPath.row];
    
    AsyncImageView *picture = (AsyncImageView *) [cell viewWithTag:10];
    if ([_data.feature_image_url isEqualToString:@""] ) {
        picture.image = [UIImage imageNamed:@"bg_photo"];
    } else {
        picture.imageURL = [NSURL URLWithString:_data.feature_image_url];
    }
    
    picture.layer.masksToBounds = YES;
    picture.layer.cornerRadius = picture.frame.size.height / 2;
    picture.layer.borderWidth = 2.0;
    picture.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UILabel *title = (UILabel *) [cell viewWithTag:11];
    NSString *_title = _data.title;
//    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_title];
//    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:14] range:NSMakeRange(0, _title.length)];
//    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(132, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
//
//    CGRect rcContent = title.frame;
//    rcContent.size.height = rect.size.height;
//    title.frame = rcContent;

    title.text = _title;
    
    UILabel *content = (UILabel *)[cell viewWithTag:12];
//    [content setFrame:CGRectMake(110, title.frame.origin.y + title.frame.size.height + 5, 132, 21)];
    NSString *_content = _data.excerpt;
    _content = [_content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    _content = [_content stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:_content];
    [attrStr1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, _content.length)];
//    CGRect rect1 = [attrStr1 boundingRectWithSize:CGSizeMake(132, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
//    
//    CGRect rcContent1 = content.frame;
//    if (rect1.size.height > (108 - 14 - rect.size.height)) {
//        rcContent1.size.height = (108 - 14 - rect.size.height - 10);
//    } else {
//        rcContent1.size.height = rect1.size.height;
//    }
//    content.frame = rcContent1;
    
    content.text = _content;
    
    UILabel *subContent = (UILabel *)[cell viewWithTag:13];
    subContent.text = @"Lorem ipsum dolor sit amet";
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewContentViewController *contentView = (NewContentViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NewContentViewController"];
    contentView.data = arrData;
    contentView.index = indexPath.row;
    
    [self.navigationController pushViewController:contentView animated:YES];
    
//    [self presentViewController:contentView animated:YES completion:Nil];
}

@end
