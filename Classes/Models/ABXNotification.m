//
//  ABXNotification.m
//
//  Created by Stuart Hall on 21/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXNotification.h"

#import "NSDictionary+ABXNSNullAsNull.h"

PROTECTED_ABXMODEL

@implementation ABXNotification

- (id)initWithAttributes:(NSDictionary*)attributes
{
    self = [super init];
    if (self) {
        self.identifier = [attributes objectForKeyNulled:@"id"];
        self.message = [attributes objectForKeyNulled:@"message"];
        self.actionLabel = [attributes objectForKeyNulled:@"action_label"];
        self.actionUrl = [attributes objectForKeyNulled:@"action_url"];
    }
    return self;
}

+ (id)createWithAttributes:(NSDictionary*)attributes
{
    return [[ABXNotification alloc] initWithAttributes:attributes];
}

+ (NSURLSessionDataTask*)fetch:(void(^)(NSArray *notifications, ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [self fetchList:@"notifications" params:nil complete:complete];
}

- (BOOL)hasAction
{
    return self.actionUrl.length > 0 && self.actionLabel.length > 0;
}

- (void)markAsSeen
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[@"Notification" stringByAppendingString:[self.identifier stringValue]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasSeen
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[@"Notification" stringByAppendingString:[self.identifier stringValue]]];
}

@end
