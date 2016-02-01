//
//  SDWarRoomsListController.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/21/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

typedef enum {
    LIST_TYPE_GROUP = 0,
    LIST_TYPE_FORUM,
    LIST_TYPE_THREAD
} GroupListType;

@interface SDForumListController : SDBaseViewController

@property (nonatomic, assign) id parentItem;
@property (nonatomic, assign) GroupListType listType;

@end
