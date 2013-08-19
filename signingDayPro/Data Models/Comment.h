//
//  Comment.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 8/14/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActivityStory, User;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) ActivityStory *activityStory;
@property (nonatomic, retain) User *user;

@end
