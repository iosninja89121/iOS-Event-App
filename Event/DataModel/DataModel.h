//
//  AboutQue.h
//  Copyright (c) Dahua. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NotifyFindBeekers       @"findBeekers"
#define NotifyNoFindBeekers     @"noFindBeekers"

@interface DataModel : NSObject {
    AppDelegate *appDelegate;
}

@property(nonatomic)int item_id;
@property(nonatomic,copy)NSString *date_gmt;
@property(nonatomic,copy)NSString *guid;
@property(nonatomic,copy)NSString *modificated_gmt;
@property(nonatomic,copy)NSString *slug;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *link;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *excerpt;
@property(nonatomic)int author;
@property(nonatomic)int featured_image;
@property(nonatomic,copy)NSString *comment_status;
@property(nonatomic,copy)NSString *ping_status;
@property(nonatomic) BOOL sticky;
@property(nonatomic,copy)NSString *format;
@property(nonatomic,copy)NSString *feature_image_url;
@property(nonatomic,copy)NSString *thumbnail_links;
@property(nonatomic,copy)NSString *author_address;
@property(nonatomic,copy)NSString *author_coordinates;
@property(nonatomic,copy)NSArray *self_links;
@property(nonatomic,copy)NSArray *collection_links;
@property(nonatomic,copy)NSArray *author_links;
@property(nonatomic,copy)NSArray *replies_links;
@property(nonatomic,copy)NSArray *version_history_links;
@property(nonatomic,copy)NSArray *attachment_links;
@property(nonatomic,copy)NSArray *term_links;
@property(nonatomic,copy)NSArray *meta_links;
@property(nonatomic) float miles;

-(id)initWithDict:(NSDictionary *)dictData;

@end

