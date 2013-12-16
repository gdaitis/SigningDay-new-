//
//  TopSchool.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player, Team;

@interface TopSchool : NSManagedObject

@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * interest;
@property (nonatomic, retain) Player *thePlayer;
@property (nonatomic, retain) Team *theTeam;

@end
