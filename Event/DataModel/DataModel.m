//
//  AboutQue.m
//  Copyright (c) Dahua. All rights reserved.
//

#import "DataModel.h"
#import <math.h>
#import "TFHpple.h"

#define WIDTH [[UIScreen mainScreen] bounds].size.width

@implementation DataModel

@synthesize item_id;
@synthesize date_gmt;
@synthesize guid;
@synthesize modificated_gmt;
@synthesize slug;
@synthesize type;
@synthesize link;
@synthesize title;
@synthesize content;
@synthesize excerpt;
@synthesize author;
@synthesize featured_image;
@synthesize comment_status;
@synthesize ping_status;
@synthesize sticky;
@synthesize format;
@synthesize feature_image_url;
@synthesize thumbnail_links;
@synthesize author_address;
@synthesize author_coordinates;
@synthesize self_links;
@synthesize collection_links;
@synthesize author_links;
@synthesize replies_links;
@synthesize version_history_links;
@synthesize attachment_links;
@synthesize term_links;
@synthesize meta_links;
@synthesize miles;


-(id)initWithDict:(NSDictionary *)dictData
{
    self=[super init];
    if (self) {
        if (dictData) {
            
            appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            
            item_id=[[dictData objectForKey:@"id"] intValue];
            date_gmt=[dictData objectForKey:@"date_gmt"];
            
            NSDictionary *_guid = [dictData objectForKey:@"guid"];
            guid=[_guid objectForKey:@"rendered"];
            
            modificated_gmt=[dictData objectForKey:@"modified_gmt"];
            slug=[dictData objectForKey:@"slug"];
            type=[dictData objectForKey:@"type"];
            link=[dictData objectForKey:@"link"];

            NSDictionary *_title = [dictData objectForKey:@"title"];
            title=[_title objectForKey:@"rendered"];
            
            NSDictionary *_content = [dictData objectForKey:@"content"];

            NSDictionary *_excerpt = [dictData objectForKey:@"excerpt"];
            excerpt=[_excerpt objectForKey:@"rendered"];
            
            author=[[dictData objectForKey:@"author"] intValue];
            featured_image=[[dictData objectForKey:@"featured_image"] intValue];
            comment_status=[dictData objectForKey:@"comment_status"];
            ping_status=[dictData objectForKey:@"ping_status"];
            sticky=[[dictData objectForKey:@"sticky"] boolValue];
            format=[dictData objectForKey:@"format"];

            NSString *content_image = @"";
            
//            if (featured_image == 0) {
//                feature_image_url=@"";
//            } else {
//                feature_image_url=[dictData objectForKey:@"featured_image_url"];
//                content_image = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>", feature_image_url, WIDTH - 15, WIDTH / 1.5];
//            }
            
            feature_image_url=[dictData objectForKey:@"featured_image_url"];
            
            if(feature_image_url == nil || [feature_image_url isKindOfClass:[NSNumber class]]){
                feature_image_url = @"";
            }else{
                if(![feature_image_url isEqualToString:@""]){
                    content_image = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>", feature_image_url, WIDTH - 15, WIDTH / 1.5];
                }
            }
            
            
            NSString *html = [_content objectForKey:@"rendered"];
            NSString *new_html = @"";
            
            NSData *someData = [html dataUsingEncoding:NSUTF8StringEncoding];
            
            TFHpple *parsing = [TFHpple hppleWithHTMLData:someData];
            
            NSArray *a = [parsing searchWithXPathQuery:@"//iframe"];
            if (a.count != 0) {
                TFHppleElement * e = [a objectAtIndex:0];
                NSString *width = [e objectForKey:@"width"];
                
                new_html = [html stringByReplacingOccurrencesOfString:width withString:[NSString stringWithFormat:@"%f", WIDTH - 15]];
            } else {
                new_html = html;
            }
            
            content=[NSString stringWithFormat:@"%@ %@", content_image, new_html];

            author_coordinates = [dictData objectForKey:@"author_coordinates"];
            if ([author_coordinates isEqualToString:@""]) {
                miles = 0.0;
            } else {
                NSArray* location = [author_coordinates componentsSeparatedByString: @","];
                double latitude = [[location objectAtIndex: 0] doubleValue];
                double longitude = [[location objectAtIndex: 1] doubleValue];
                
                CLLocation *locA = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                CLLocation *locB = [[CLLocation alloc] initWithLatitude:appDelegate.latitude longitude:appDelegate.longitude];
                
                float _miles = [self kilometersfromPlace:locB andToPlace:locA] / 1.609344;
                
//                float _miles = [self calculateDistance:appDelegate.longitude fromLat:appDelegate.latitude toLong:longitude toLat:latitude] / 1000 / 1.609344;
                
                miles=_miles;
            }
        }
    }
    return self;
}

-(float)kilometersfromPlace:(CLLocation *)from andToPlace:(CLLocation *)to  {
    
    CLLocationDistance dist = [from distanceFromLocation:to]/1000;
    
    //NSLog(@"%f",dist);
    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
}

-(double)calculateDistance:(double)fromLong fromLat:(double)fromLat toLong:(double)toLong toLat:(double)toLat {
    double d2r = M_PI / 180;
    double dLong = (toLong - fromLong) * d2r;
    double dLat = (toLat - fromLat) * d2r;
    double a = pow(sin(dLat / 2.0), 2) + cos(fromLat * d2r) * cos(toLat * d2r) * pow(sin(dLong / 2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = 6367000 * c;
    return round(d);
}

@end