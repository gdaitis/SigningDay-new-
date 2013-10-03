//
//  Like.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 10/3/13.
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
