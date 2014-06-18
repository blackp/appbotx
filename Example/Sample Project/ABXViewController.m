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
    // This is a convenient wrapper, or dig in and control it yourself
    [ABXVersionNotificationView fetchAndShowInController:self
                                             foriTunesID:kiTunesID
                                         backgroundColor:[UIColor colorWithRed:0xf4/255.0 green:0x7d/255.0 blue:0x67/255.0 alpha:1]
                                               textColor:[UIColor blackColor]
                                             buttonColor:[UIColor whiteColor]];
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

#pragma mark - ABXPromptViewDelegate

- (void)appbotPromptForReview
{
    [ABXAppStore openAppStoreReviewForApp:kiTunesID];
    self.promptView.hidden = YES;
}

- (void)appbotPromptForFeedback
{
    [ABXFeedbackViewController showFromController:self placeholder:nil];
    self.promptView.hidden = YES;
}

@end
