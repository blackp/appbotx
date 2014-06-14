//
//  ABXFaq.m
//
//  Created by Stuart Hall on 21/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXFaq.h"

#import "NSDictionary+ABXNSNullAsNull.h"

PROTECTED_ABXMODEL

@implementation ABXFaq

- (id)initWithAttributes:(NSDictionary*)attributes
{
    self = [super init];
    if (self) {
        self.identifier = [attributes objectForKeyNulled:@"id"];
        self.question = [attributes objectForKeyNulled:@"question"];
        self.answer = [attributes objectForKeyNulled:@"answer"];
    }
    return self;
}

+ (id)createWithAttributes:(NSDictionary*)attributes
{
    return [[ABXFaq alloc] initWithAttributes:attributes];
}

+ (NSURLSessionDataTask*)fetch:(void(^)(NSArray *faqs, ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [self fetchList:@"faqs" params:nil complete:complete];
}

- (NSURLSessionDataTask*)upvote:(void(^)(ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [self vote:@"upvote" complete:complete];
}

- (NSURLSessionDataTask*)downvote:(void(^)(ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [self vote:@"downvote" complete:complete];
}

- (NSURLSessionDataTask*)vote:(NSString*)action complete:(void(^)(ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [[ABXApiClient instance] PUT:[NSString stringWithFormat:@"faqs/%@/%@", _identifier, action]
                                 params:nil
                               complete:^(ABXResponseCode responseCode, NSInteger httpCode, NSError *error, id JSON) {
                                   if (complete) {
                                       complete(responseCode, httpCode, error);
                                   }
                               }];
}

- (NSURLSessionDataTask*)recordView:(void(^)(ABXResponseCode responseCode, NSInteger httpCode, NSError *error))complete
{
    return [[ABXApiClient instance] GET:[NSString stringWithFormat:@"faqs/%@", _identifier]
                                 params:nil
                               complete:^(ABXResponseCode responseCode, NSInteger httpCode, NSError *error, id JSON) {
                                   if (complete) {
                                       complete(responseCode, httpCode, error);
                                   }
                               }];
}

@end
