//
//  SDFilterListViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

typedef enum {
	LIST_TYPE_STATES = 0,
	LIST_TYPE_YEARS,
    LIST_TYPE_POSITIONS
} FilterListType;



@class State;
@class SDFilterListViewController;

@protocol SDFilterListDelegate <NSObject>

@optional
- (void)stateChosen:(State *)state inFilterListController:(SDFilterListViewController *)filterListViewController;
- (void)yearsChosen:(NSDictionary *)years inFilterListController:(SDFilterListViewController *)filterListViewController;
- (void)positionChosen:(NSDictionary *)position inFilterListController:(SDFilterListViewController *)filterListViewController;

@end

@interface SDFilterListViewController : SDBaseViewController

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) id selectedItem;
@property (nonatomic, weak) id <SDFilterListDelegate> delegate;
@property (nonatomic, assign) FilterListType filterListType;

@end























