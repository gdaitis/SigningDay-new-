//
//  Notification.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 10/1/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master, User;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSString * contentId;
@property (nonatomic, retain) NSString * contentTypeId;
@property (nonatomic, retain) NSString * contentTypeName;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSNumber * notificationTypeId;
@property (nonatomic, retain) NSString * activityStoryId;
@property (nonatomic, retain) User *fromUser;
@property (nonatomic, retain) Master *master;

@end
