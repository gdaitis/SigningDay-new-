//
//  Organization.h
//  SigningDay
//
//  Created by lite on 27/01/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Organization : NSManagedObject

@property (nonatomic, retain) NSString * coFounder;
@property (nonatomic, retain) User *theUser;

@end
