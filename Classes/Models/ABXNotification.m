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
        
        // Date formatter, cache as they are expensive to create
        static dispatch_once_t onceToken;
        static NSDateFormatter *formatter = nil;
        dispatch_once(&onceToken, ^{
            formatter = [NSDateFormatter new];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
        });
        
        NSString *createdAtString = [attributes objectForKeyNulled:@"created_at"];
        if (createdAtString != nil) {
            self.createdAt = [formatter dateFromString:createdAtString];
        }
    }
    return self;
}

+ (id)createWithAttributes:(NSDictionary*)attributes
{
    return [[ABXNotification alloc] initWithAttributes:attributes];
}

+ (NSURLSessionDataTask*)fetchActive:(void(^)(NSArray *notifications, ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [self fetchList:@"notifications/active" params:nil complete:complete];
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
