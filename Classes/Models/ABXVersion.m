//
//  ABXVersion.m
//
//  Created by Stuart Hall on 21/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXVersion.h"

#import "NSDictionary+ABXNSNullAsNull.h"
#import "ABXKeychain.h"

PROTECTED_ABXMODEL

@implementation ABXVersion

- (id)initWithAttributes:(NSDictionary*)attributes
{
    self = [super init];
    if (self) {
        // Date formatter, cache as they are expensive to create
        static dispatch_once_t onceToken;
        static NSDateFormatter *formatter = nil;
        dispatch_once(&onceToken, ^{
            formatter = [NSDateFormatter new];
            [formatter setDateFormat:@"yyyy-MM-dd"];
        });
        
        // Convert the string to a date
        NSString *releaseDateString = [attributes objectForKeyNulled:@"release_date"];
        if (releaseDateString) {
            self.releaseDate = [formatter dateFromString:releaseDateString];
        }
        
        self.text = [attributes objectForKeyNulled:@"change_text"];
        self.version = [attributes objectForKeyNulled:@"version"];
    }
    return self;
}

+ (id)createWithAttributes:(NSDictionary*)attributes
{
    return [[ABXVersion alloc] initWithAttributes:attributes];
}

+ (NSURLSessionDataTask*)fetch:(void(^)(NSArray *versions, ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [self fetchList:@"versions" params:nil complete:complete];
}

+ (NSURLSessionDataTask*)fetchCurrentVersion:(void(^)(ABXVersion *version, ABXVersion *latestVersion, ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [[ABXApiClient instance] GET:@"versions"
                                 params:@{ @"version" : NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"] }
                               complete:^(ABXResponseCode responseCode, NSInteger httpCode, NSError *error, id JSON) {
                                   if (responseCode == ABXResponseCodeSuccess) {
                                       NSDictionary *results = [JSON objectForKeyNulled:@"results"];
                                       if (results && [results isKindOfClass:[NSDictionary class]]) {
                                           // Convert into objects
                                           ABXVersion *version = nil;
                                           ABXVersion *currentVersion = nil;
                                           
                                           if ([results objectForKeyNulled:@"version"]) {
                                               version = [self createWithAttributes:[results objectForKeyNulled:@"version"]];
                                           }
                                           
                                           if ([results objectForKeyNulled:@"current_version"]) {
                                               currentVersion = [self createWithAttributes:[results objectForKeyNulled:@"current_version"]];
                                           }
                                           
                                           // Success!
                                           if (complete) {
                                               complete(version, currentVersion, responseCode, httpCode, error);
                                           }
                                       }
                                       else {
                                           // Decoding error, pass the values through
                                           if (complete) {
                                               complete(nil, nil, ABXResponseCodeErrorDecoding, httpCode, error);
                                           }
                                       }
                                   }
                                   else {
                                       // Error, pass the values through
                                       if (complete) {
                                           complete(nil, nil, responseCode, httpCode, error);
                                       }
                                   }
                               }];
}

- (void)markAsSeen
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[@"Version" stringByAppendingString:self.version]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasSeen
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[@"Version" stringByAppendingString:self.version]];
}

- (BOOL)isNewerThanCurrent
{
    return [self.version compare:NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"] options:NSNumericSearch] == NSOrderedDescending;
}

@end
