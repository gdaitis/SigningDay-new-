//
//  SDFilterListViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@class SDFilterListViewController;

@protocol SDFilterListDelegate <NSObject>

@optional

//needs optional methods

@end

@interface SDFilterListViewController : SDBaseViewController

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int selectedRow;
@property (nonatomic, weak) id <SDFilterListDelegate> delegate;

@end























