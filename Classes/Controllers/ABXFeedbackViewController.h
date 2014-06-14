//
//  ABXFeedbackViewController.h
//  Sample Project
//
//  Created by Stuart Hall on 30/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABXFeedbackViewController : UIViewController

@property (nonatomic, copy) NSString *placeholder;

+ (void)showFromController:(UIViewController*)controller placeholder:(NSString*)placeholder;

// Provide a custom email to default to
+ (void)showFromController:(UIViewController*)controller placeholder:(NSString*)placeholder email:(NSString*)email;

@end
