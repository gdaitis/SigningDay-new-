//
//  SDWebViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/10/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SDCommonWebViewController.h"

@interface SDWebViewController : SDCommonWebViewController

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *gaScreenName;
@property (nonatomic, strong) NSString *navigationTitle;

@end
