//
//  ABXVersionTableViewCell.h
//  Sample Project
//
//  Created by Stuart Hall on 22/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABXVersion;

@interface ABXVersionTableViewCell : UITableViewCell

- (void)setVersion:(ABXVersion*)version;

+ (CGFloat)heightForVersion:(ABXVersion*)version withWidth:(CGFloat)width;

@end
