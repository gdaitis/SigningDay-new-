//
//  Offer.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player, Team;

@interface Offer : NSManagedObject

@property (nonatomic, retain) NSNumber * playerCommited;
@property (nonatomic, retain) Team *team;
@property (nonatomic, retain) Player *player;

@end
