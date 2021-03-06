//
//  ABXPromptView.h
//  Sample Project
//
//  Created by Stuart Hall on 30/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ABXPromptViewDelegate <NSObject>

- (void)appbotPromptForReview;
- (void)appbotPromptForFeedback;

@end

@interface ABXPromptView : UIView

@property (weak) id<ABXPromptViewDelegate> delegate;

+ (BOOL)hasHadInteractionForCurrentVersion;

@property (nonatomic, strong) UIColor *backgroundColor;

@end