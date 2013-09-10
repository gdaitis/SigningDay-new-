//
//  Conference.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/10/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Conference : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * nameShort;
@property (nonatomic, retain) NSString * nameFull;
@property (nonatomic, retain) NSString * logoUrl;
@property (nonatomic, retain) NSString * logoUrlBlack;
@property (nonatomic, retain) NSNumber * isDivision1Conference;

@end
