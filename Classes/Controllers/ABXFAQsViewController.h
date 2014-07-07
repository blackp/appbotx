//
//  ABXFAQsViewController.h
//
//  Created by Stuart Hall on 21/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABXBaseListViewController.h"

@interface ABXFAQsViewController : ABXBaseListViewController

+ (void)showFromController:(UIViewController*)controller
         hideContactButton:(BOOL)hideContactButton
           contactMetaData:(NSDictionary*)contactMetaData;

@property (nonatomic, assign) BOOL hideContactButton;
@property (nonatomic, strong) NSDictionary *contactMetaData;

/**
 *  Filter term. If set, no search bar will be added, but only FAQs matching the filter term will be shown.
 */
@property (nonatomic, strong) NSString *filterTerm;

@end
