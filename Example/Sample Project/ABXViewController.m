//
//  ABXViewController.m
//  Sample Project
//
//  Created by Stuart Hall on 21/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXViewController.h"

#import "ABX.h"
#import "ABXPromptView.h"

@interface ABXViewController ()<ABXPromptViewDelegate>

@property (nonatomic, strong) IBOutlet ABXPromptView *promptView;

@end

@implementation ABXViewController

static NSString* const kiTunesID = @"650762525";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The prompt view is an example workflow using AppbotX
    // you could choose to hide it if it's been seen already
    // [ABXPromptView hasHadInteractionForCurrentVersion]
    // It's also good to only show it after a positive interaction
    // or a number of usages of the app
    self.promptView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Buttons

- (IBAction)onFetchNotifications:(id)sender
{
    // Fetch the notifications, there will only ever be one
    [ABXNotification fetch:^(NSArray *notifications, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        switch (responseCode) {
            case ABXResponseCodeSuccess: {
                if (notifications.count > 0) {
                    ABXNotification *notification = [notifications firstObject];
                    
                    if (![notification hasSeen]) {
                        // Show the view
                        [ABXNotificationView show:notification.message
                                       actionText:notification.actionLabel
                                  backgroundColor:[UIColor colorWithRed:0x86/255.0 green:0xcc/255.0 blue:0xf1/255.0 alpha:1]
                                        textColor:[UIColor blackColor]
                                      buttonColor:[UIColor whiteColor]
                                     inController:self
                                      actionBlock:^(ABXNotificationView *view) {
                                          // Open the URL
                                          // Here you could open it in your internal UIWebView or route accordingly
                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notification.actionUrl]];
                                      } dismissBlock:^(ABXNotificationView *view) {
                                          // Here you can mark it as seen if you
                                          // don't want it to appear again
                                          // [notification markAsSeen];
                                      }];
                    }
                }
                else {
                    [self showAlert:@"Notification" message:@"No notifications"];
                }
            }
                break;
                
            default: {
                [self showAlert:@"Notification Error" message:[NSString stringWithFormat:@"%u", responseCode]];
            }
                break;
        }
    }];
}

- (IBAction)onFetchVersions:(id)sender
{
    [ABXVersion fetch:^(NSArray *versions, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        switch (responseCode) {
            case ABXResponseCodeSuccess: {
                [self showAlert:@"Versions" message:[NSString stringWithFormat:@"Received %ld versions", (unsigned long)versions.count]];
            }
                break;
                
            default: {
                [self showAlert:@"Versions" message:[NSString stringWithFormat:@"%u", responseCode]];
            }
                break;
        }
    }];
}

- (IBAction)onFetchCurrentVersion:(id)sender
{
    [ABXVersion fetchCurrentVersion:^(ABXVersion *version, ABXVersion *currentVersion, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        if (responseCode == ABXResponseCodeSuccess) {
            if (currentVersion && [currentVersion isNewerThanCurrent]) {
                // Check if it is live on the store
                [currentVersion isLiveVersion:kiTunesID country:@"us" complete:^(BOOL matches) {
                    if (matches) {
                        // Show the view
                        [ABXNotificationView show:[NSString stringWithFormat:@"An update to version %@ is available", currentVersion.version]
                                       actionText:NSLocalizedString(@"Update", nil)
                                  backgroundColor:[UIColor colorWithRed:0xf4/255.0 green:0x7d/255.0 blue:0x67/255.0 alpha:1]
                                        textColor:[UIColor blackColor]
                                      buttonColor:[UIColor whiteColor]
                                     inController:self
                                      actionBlock:^(ABXNotificationView *view) {
                                          // Throw them to the App Store
                                          [view dismiss];
                                          [self openAppStoreForApp:kiTunesID];
                                      }
                                     dismissBlock:^(ABXNotificationView *view) {
                                         // Any action you want
                                     }];
                    }
                }];
            }
            else if (version) {
                // We got a match!
                if ([version hasSeen]) {
                    NSLog(@"Already shown this version");
                }
                else {
                    // Show the view
                    [ABXNotificationView show:[NSString stringWithFormat:@"You've just updated to v%@", version.version]
                                   actionText:NSLocalizedString(@"Learn More", nil)
                              backgroundColor:[UIColor colorWithRed:0xf4/255.0 green:0x7d/255.0 blue:0x67/255.0 alpha:1]
                                    textColor:[UIColor blackColor]
                                  buttonColor:[UIColor whiteColor]
                                 inController:self
                                  actionBlock:^(ABXNotificationView *view) {
                                      // Take them to all the versions, or you could choose
                                      // to just show the one version
                                      [view dismiss];
                                      [ABXVersionsViewController showFromController:self];
                                  }
                                 dismissBlock:^(ABXNotificationView *view) {
                                     // Here you can mark it as seen if you
                                     // don't want it to appear again
                                     // [version markAsSeen];
                                 }];
                }
            }
        }
    }];
}

- (IBAction)onFetchFAQs:(id)sender
{
    [ABXFaq fetch:^(NSArray *faqs, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        switch (responseCode) {
            case ABXResponseCodeSuccess: {
                [self showAlert:@"FAQs" message:[NSString stringWithFormat:@"Received %ld faqs", (unsigned long)faqs.count]];
            }
                break;
                
            default: {
                [self showAlert:@"FAQs" message:[NSString stringWithFormat:@"%u", responseCode]];
            }
                break;
        }
    }];
}

- (IBAction)showFAQs:(id)sender
{
    [ABXFAQsViewController showFromController:self hideContactButton:NO];
}

- (IBAction)showVersions:(id)sender
{
    [ABXVersionsViewController showFromController:self];
}

- (IBAction)showFeedback:(id)sender
{
    [ABXFeedbackViewController showFromController:self placeholder:nil];
}

#pragma mark - Alert

- (void)showAlert:(NSString*)title message:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}

#pragma mark - App Store

- (void)openAppStoreReviewForApp:(NSString*)itunesId
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.1" options:NSNumericSearch] != NSOrderedAscending) {
        // Since 7.1 we can throw to the review tab
        NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&ct=appbotReviewPrompt&at=11l4LZ&type=Purple%%252BSoftware&mt=8&sortOrdering=2", itunesId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else {
        [self openAppStoreForApp:itunesId];
    }
}

- (void)openAppStoreForApp:(NSString*)itunesId
{
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/au/app/app/id%@?mt=8", itunesId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - ABXPromptViewDelegate

- (void)appbotPromptForReview
{
    [self openAppStoreReviewForApp:kiTunesID];
    self.promptView.hidden = YES;
}

- (void)appbotPromptForFeedback
{
    [ABXFeedbackViewController showFromController:self placeholder:nil];
    self.promptView.hidden = YES;
}

@end
