//
//  ForumReply.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Thread, User;

@interface ForumReply : NSManagedObject

@property (nonatomic, retain) NSString * bodyText;
@property (nonatomic, retain) NSNumber * countOfBelieves;
@property (nonatomic, retain) NSNumber * countOfHates;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) User *authorUser;
@property (nonatomic, retain) Thread *thread;

@end
