//
//  NSObject+MasterUserMethods.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/18/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Master, User;

@interface NSObject (MasterUserMethods)

- (Master *)getMaster;
- (NSNumber *)getMasterIdentifier;
- (User *)getMasterUser;

+ (Master *)getMaster;
+ (NSNumber *)getMasterIdentifier;
+ (User *)getMasterUser;

@end
