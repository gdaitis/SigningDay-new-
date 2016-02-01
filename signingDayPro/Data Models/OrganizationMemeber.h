//
//  OrganizationMemeber.h
//  SigningDay
//
//  Created by lite on 28/01/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Organization, User;

@interface OrganizationMemeber : NSManagedObject

@property (nonatomic, retain) NSString * collegeName;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSString * nflpaAvatarUrl;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * teamName;
@property (nonatomic, retain) NSString * websiteTitle;
@property (nonatomic, retain) NSString * websiteUrl;
@property (nonatomic, retain) NSNumber * yearsPro;
@property (nonatomic, retain) Organization *organization;
@property (nonatomic, retain) User *theUser;

@end
