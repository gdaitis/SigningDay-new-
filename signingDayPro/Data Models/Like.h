//
//  Like.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActivityStory, User;

@interface Like : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) ActivityStory *activityStory;
@property (nonatomic, retain) User *user;

@end
