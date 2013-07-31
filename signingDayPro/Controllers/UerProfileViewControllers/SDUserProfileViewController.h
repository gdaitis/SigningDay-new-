//
//  SDViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"
#import "SDUserProfileHeaderDelegate.h"

@interface SDUserProfileViewController : SDBaseViewController <UITableViewDataSource,UITableViewDelegate,SDUserProfileHeaderDelegate>

@property (nonatomic, strong) User *currentUser;

@end
