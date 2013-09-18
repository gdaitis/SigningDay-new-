//
//  WebPreview.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActivityStory;

@interface WebPreview : NSManagedObject

@property (nonatomic, retain) NSString * excerpt;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * siteName;
@property (nonatomic, retain) NSString * webPreviewTitle;
@property (nonatomic, retain) ActivityStory *activityStory;

@end
