//
//  ABXNotificationTableViewCell.h
//  Sample Project
//
//  Created by Stuart Hall on 18/06/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABXNotificationTableViewCell : UITableViewCell

- (void)setNotification:(ABXNotification *)notification;

+ (CGFloat)heightForNotification:(ABXNotification*)notification withWidth:(CGFloat)width;

@end
