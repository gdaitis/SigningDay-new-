//
//  NFLPA.h
//  SigningDay
//
//  Created by Lukas Kekys on 11/7/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface NFLPA : NSManagedObject

@property (nonatomic, retain) NSString * collegeName;
@property (nonatomic, retain) NSString * nflpaAvatarUrl;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * teamName;
@property (nonatomic, retain) NSString * websiteTitle;
@property (nonatomic, retain) NSString * websiteUrl;
@property (nonatomic, retain) NSNumber * yearsPro;
@property (nonatomic, retain) User *theUser;

@end
