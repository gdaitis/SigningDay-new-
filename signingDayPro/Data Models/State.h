//
//  State.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/16/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface State : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * isInUS;
@property (nonatomic, retain) NSString * name;

@end
