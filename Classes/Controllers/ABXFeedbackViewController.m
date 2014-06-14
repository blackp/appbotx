//
//  ABXFeedbackViewController.m
//  Sample Project
//
//  Created by Stuart Hall on 30/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXFeedbackViewController.h"

#import "ABXKeychain.h"
#import "ABXTextView.h"
#import "ABXIssue.h"

@interface ABXFeedbackViewController ()<UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSString *defaultEmail;

@property (nonatomic, strong) ABXTextView *textView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) ABXKeychain *keychain;

@end

@implementation ABXFeedbackViewController

static NSInteger const kEmailAlert = 0;
static NSInteger const kCloseAlert = 1;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Listen for keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Email label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 90, 50)];
    label.textColor = [UIColor grayColor];
    label.text = NSLocalizedString(@"Your Email:", nil);
    label.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:label];
    
    // Field for their email
    CGRect tfRect = CGRectMake(110, 0, CGRectGetWidth(self.view.frame) - 120, 50);
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending) {
        tfRect = CGRectMake(110, 15, CGRectGetWidth(self.view.frame) - 120, 31);
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:tfRect];
    textField.placeholder = @"e.g. yourname@icloud.com";
    textField.font = [UIFont systemFontOfSize:15];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.returnKeyType = UIReturnKeyNext;
    textField.delegate = self;
    [self.view addSubview:textField];
    self.textField = textField;
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(20, 50, CGRectGetWidth(self.view.frame), [UIScreen mainScreen].scale >= 2.0f ? 0.5 : 1)];
    seperator.backgroundColor = [UIColor lightGrayColor];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:seperator];
    
    // Text view
    self.textView = [[ABXTextView alloc] initWithFrame:CGRectMake(15, 51, CGRectGetWidth(self.view.frame) - 30, CGRectGetHeight(self.view.frame) - 51)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.placeholder = self.placeholder ?: NSLocalizedString(@"How can we help?", nil);
    self.textView.delegate = self;
    [self.view addSubview:self.textView];
    
    // Title
    self.title = NSLocalizedString(@"Contact", nil);
    
    // Buttons
    [self showButtons];
    
    if (self.defaultEmail.length > 0) {
        // An email has been provided
        self.textField.text = self.defaultEmail;
    }
    else {
        // Set the email from the keychain if has been entered before
        self.keychain = [[ABXKeychain alloc] initWithService:@"appbot.co" accessGroup:nil accessibility:ABXKeychainAccessibleWhenUnlocked];
        self.textField.text = self.keychain[@"FeedbackEmail"];
    }
    
    if (self.textField.text.length > 0) {
        [self.textView becomeFirstResponder];
    }
    else {
        [self.textField becomeFirstResponder];
    }
}

+ (void)showFromController:(UIViewController*)controller placeholder:(NSString*)placeholder email:(NSString*)email
{
    ABXFeedbackViewController *viewController = [[self alloc] init];
    viewController.placeholder = placeholder;
    viewController.defaultEmail = email;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Show as a sheet on iPad
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [controller presentViewController:nav animated:YES completion:nil];
}

+ (void)showFromController:(UIViewController*)controller placeholder:(NSString*)placeholder
{
    [self showFromController:controller placeholder:placeholder email:nil];
}

#pragma mark Keyboard

- (void)onKeyboard:(NSNotification*)notification
{
    CGRect keyboardWinRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    // Convert it to suit us
    CGRect keyboardRect = [self.view convertRect:keyboardWinRect fromView:self.view.window];
    
    // Move the textView so the bottom doesn't extend beyound the keyboard
    CGRect tvFrame = self.textView.frame;
    tvFrame.size.height = CGRectGetHeight(self.view.bounds) - (CGRectGetHeight(keyboardRect) + CGRectGetMinY(tvFrame));
    self.textView.frame = tvFrame;
}

- (void)showButtons
{
    if (self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(onDone)];
    }
    
    if (self.textView.text.length > 0 && self.navigationItem.rightBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil)
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(onSend)];
    }
    else if (self.textView.text.length == 0 && self.navigationItem.rightBarButtonItem != nil) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)onDone
{
    if (self.textView.text.length > 0) {
        // Prompt to ensure they want to close
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                                        message:NSLocalizedString(@"Your message will be lost.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Close", nil), nil];
        alert.tag = kCloseAlert;
        [alert show];
    }
    else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onSend
{
    [self validateAndSend];
}

#pragma mark - Validation

- (BOOL)validateEmail
{
    NSString *regex1 = @"\\A[a-z0-9]+([-._][a-z0-9]+)*@([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,4}\\z";
    NSString *regex2 = @"^(?=.{1,64}@.{4,64}$)(?=.{6,100}$).*";
    NSPredicate *test1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    NSPredicate *test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    return [test1 evaluateWithObject:self.textField.text] && [test2 evaluateWithObject:self.textField.text];
}

- (void)validateAndSend
{
    [self.textView resignFirstResponder];
    [self.textField resignFirstResponder];
    
    if (self.textView.text.length == 0) {
        // Needs a body
        [self.textView becomeFirstResponder];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Message.", nil)
                                    message:NSLocalizedString(@"Please enter a message.", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
        
    }
    else if (self.textField.text.length == 0) {
        // Ensure they want to submit without an email
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Email.", nil)
                                    message:NSLocalizedString(@"Are you sure you want to send without your email? We won't be able reply to you.", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               otherButtonTitles:NSLocalizedString(@"Send", nil), nil];
        alert.tag = kEmailAlert;
        [alert show];
    }
    else if (![self validateEmail]) {
        // Invalid email
        [self.textField becomeFirstResponder];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Email Address.", nil)
                                    message:NSLocalizedString(@"Please check your email address, it appears to be invalid.", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    }
    else {
        // All good!
        [self send];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kEmailAlert: {
            if (buttonIndex == 1) {
                [self send];
            }
            else {
                [self.textField becomeFirstResponder];
            }
        }
            break;
            
        case kCloseAlert: {
            if (buttonIndex == 1) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }

}

#pragma mark - Submission

- (void)send
{
    if (self.textField.text.length > 0) {
        // Save the email in the keychain
        self.keychain[@"FeedbackEmail"] = self.textField.text;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    overlay.backgroundColor = [UIColor clearColor];
    [self.view addSubview:overlay];
    
    UIView *smoke = [[UIView alloc] initWithFrame:self.view.bounds];
    smoke.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    smoke.backgroundColor = [UIColor blackColor];
    smoke.alpha = 0.5;
    [overlay addSubview:smoke];
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(overlay.frame), 50)];
    content.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    content.center = smoke.center;
    [overlay addSubview:content];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.center = CGPointMake(CGRectGetMidX(content.bounds), CGRectGetMidY(content.bounds) - 10);
    [activity startAnimating];
    [content addSubview:activity];
    
    UILabel *label = [[UILabel alloc] initWithFrame:content.bounds];
    label.center = CGPointMake(CGRectGetMidX(content.bounds), CGRectGetMidY(content.bounds) + 30);
    label.textColor = [UIColor whiteColor];
    label.text = @"Sending...";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    [content addSubview:label];
    
    [ABXIssue submit:self.textField.text
            feedback:self.textView.text
            complete:^(ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
                switch (responseCode) {
                    case ABXResponseCodeSuccess: {
                        [self.navigationController dismissViewControllerAnimated:YES
                                                                      completion:^{
                                                                          [self showConfirm];
                                                                      }];
                    }
                        break;
                
                    default: {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                        message:NSLocalizedString(@"There was an error sending your feedback, please try again.", nil)
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                               otherButtonTitles:nil];
                        [alert show];
                        [self showButtons];
                        [overlay removeFromSuperview];
                    }
                        break;
                }
            }];
}

- (void)showConfirm
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thanks", nil)
                                                    message:NSLocalizedString(@"We have received your feedback and will be in contact soon.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self showButtons];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textView becomeFirstResponder];
    
    return NO;
}

@end

