//
//  Message.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation, User;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Conversation *conversation;
@property (nonatomic, retain) User *user;

@end
