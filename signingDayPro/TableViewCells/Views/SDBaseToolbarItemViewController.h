//
//  SDBaseToolbarItemViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#define kBaseToolbarItemViewControllerHeaderHeight 40
#define kBaseToolbarItemViewControllerRowHeight 50

#import <UIKit/UIKit.h>
#import "SDTableView.h"
#import "SDBaseViewController.h"

@interface SDBaseToolbarItemViewController : SDBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, weak) IBOutlet SDTableView *tableView;

@end

