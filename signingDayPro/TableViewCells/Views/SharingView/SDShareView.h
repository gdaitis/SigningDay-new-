//
//  SDShareView.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/16/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDShareView;

@protocol SDShareViewDelegate <NSObject>

@optional

- (void)shareButtonSelectedInShareView:(SDShareView *)shareView withShareText:(NSString *)shareText facebookEnabled:(BOOL)facebookEnabled twitterEnabled:(BOOL)twitterEnabled;
- (void)dontShareButtonSelectedInShareView:(SDShareView *)shareView;

@end

@interface SDShareView : UIView

@property (nonatomic, strong) NSString *shareText;
@property (nonatomic, weak) id <SDShareViewDelegate> delegate;

@end
