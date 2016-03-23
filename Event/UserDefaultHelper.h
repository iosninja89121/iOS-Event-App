//
//  UserDefaultHelper.h
//
//  Copyright (c) Dahua. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USERDEFAULT [NSUserDefaults standardUserDefaults]

//UserDefault Keys
extern NSString *const UD_STATUS;//AccessToken

@interface UserDefaultHelper : NSObject
{
}
-(id)init;
+(UserDefaultHelper *)sharedObject;

//getter
-(NSString *)getStatus;

-(void)setStatus:(NSString *)status;


@end
