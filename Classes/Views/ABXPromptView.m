//
//  ABXPromptView.m
//  Sample Project
//
//  Created by Stuart Hall on 30/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXPromptView.h"

#import "NSString+ABXLocalized.h"

@interface ABXPromptView ()

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *largeButton;

@property (nonatomic, assign) BOOL liked;

@end

@implementation ABXPromptView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialise];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialise];
    }
    return self;
}

#pragma mark - Setup

- (void)initialise
{
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 100)];
    self.container.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.container.backgroundColor = [UIColor clearColor];
    [self addSubview:self.container];
    self.container.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.container.bounds), 52)];
    self.label.textColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.label.text = [[[@"What do you think about " localizedString] stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]] stringByAppendingString:@"?"];
    [self.container addSubview:self.label];
    
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.frame = CGRectMake(CGRectGetMidX(self.container.bounds) - 135, 50, 130, 30);
    self.leftButton.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1];
    self.leftButton.layer.cornerRadius = 4;
    self.leftButton.layer.masksToBounds = YES;
    [self.leftButton setTitle:[@"I Love It!" localizedString] forState:UIControlStateNormal];
    [self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.leftButton addTarget:self action:@selector(onLove) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.frame = CGRectMake(CGRectGetMidX(self.container.bounds) + 5, 50, 130, 30);
    self.rightButton.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1];
    self.rightButton.layer.cornerRadius = 4;
    self.rightButton.layer.masksToBounds = YES;
    [self.rightButton setTitle:[@"Could Be Better" localizedString] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.rightButton addTarget:self action:@selector(onImprove) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:self.rightButton];
    
    self.largeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.largeButton.frame = CGRectMake(CGRectGetMidX(self.container.bounds) - 100, 50, 200, 30);
    self.largeButton.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1];
    self.largeButton.layer.cornerRadius = 4;
    self.largeButton.layer.masksToBounds = YES;
    [self.largeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.largeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.largeButton addTarget:self action:@selector(onLargeButton) forControlEvents:UIControlEventTouchUpInside];
    self.largeButton.alpha = 0;
    [self.container addSubview:self.largeButton];
}

#pragma mark - Buttons

- (void)onLove
{
    self.liked = YES;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.label.text = [@"Great! Could you leave us a nice review?\r\nIt really helps."  localizedString];
                         [self.largeButton setTitle:[@"Leave a Review" localizedString] forState:UIControlStateNormal];
                         [self.closeButton setTitle:[@"no thanks" localizedString] forState:UIControlStateNormal];
                         self.leftButton.alpha = 0;
                         self.rightButton.alpha = 0;
                         self.largeButton.alpha = 1;
                     }];
}

- (void)onImprove
{
    self.liked = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.label.text = [@"Could you tell us how we could improve?" localizedString];
                         [self.largeButton setTitle:[@"Send Feedback" localizedString] forState:UIControlStateNormal];
                         [self.closeButton setTitle:[@"no thanks" localizedString] forState:UIControlStateNormal];
                         self.leftButton.alpha = 0;
                         self.rightButton.alpha = 0;
                         self.largeButton.alpha = 1;
                     }];
}

- (void)onLargeButton
{
    [[self class] setHasHadInteractionForCurrentVersion];
    
    if (self.liked && self.delegate && [self.delegate respondsToSelector:@selector(appbotPromptForReview)]) {
        [self.delegate appbotPromptForReview];
    }
    else if (!self.liked && self.delegate && [self.delegate respondsToSelector:@selector(appbotPromptForFeedback)]) {
        [self.delegate appbotPromptForFeedback];
    }
}

static NSString* const kInteractionKey = @"ABXPromptViewInteraction";

+ (NSString*)keyForCurrentVersion
{
    NSString *version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    return [kInteractionKey stringByAppendingString:version];
}

+ (BOOL)hasHadInteractionForCurrentVersion
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self keyForCurrentVersion]];
}

+ (void)setHasHadInteractionForCurrentVersion
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[self keyForCurrentVersion]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
