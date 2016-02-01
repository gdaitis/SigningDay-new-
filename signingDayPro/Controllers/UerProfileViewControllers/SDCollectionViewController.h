//
//  SDCollectionViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"
#import "SDProfileService.h"

@class User;

@interface SDCollectionViewController : SDBaseViewController

@property (nonatomic, strong) User *user;
@property (nonatomic) SDGalleryType galleryType;

@end
