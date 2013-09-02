//
//  Coach.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Team, User;

@interface Coach : NSManagedObject

@property (nonatomic, retain) NSString * institution;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) Team *team;
@property (nonatomic, retain) User *theUser;

@end
