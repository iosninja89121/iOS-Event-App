//
//  UserDefaultHelper.m
//
//  Copyright (c) Dahua. All rights reserved.
//


#import "UserDefaultHelper.h"

//UserDefault Keys
NSString *const UD_STATUS = @"status";

@implementation UserDefaultHelper

#pragma mark -
#pragma mark - Init

-(id)init
{
    if((self = [super init]))
    {

    }
    return self;
}

+(UserDefaultHelper *)sharedObject
{
    static UserDefaultHelper *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[UserDefaultHelper alloc] init];
    });
    return obj;
}

#pragma mark -
#pragma mark - SetAllData

-(NSString *)getStatus
{
    return [USERDEFAULT objectForKey:UD_STATUS];
}

#pragma mark -
#pragma mark - Setter

-(void)setStatus:(NSString *)status
{
    [USERDEFAULT setObject:status forKey:UD_STATUS];
    [USERDEFAULT synchronize];
}

@end
