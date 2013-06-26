//
//  ActivityStory.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Like, Master, User;

@interface ActivityStory : NSManagedObject

@property (nonatomic, retain) NSString * contentId;
@property (nonatomic, retain) NSString * contentTypeId;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate * lastUpdateDate;
@property (nonatomic, retain) NSString * storyTypeId;
@property (nonatomic, retain) NSString * activityTitle;
@property (nonatomic, retain) NSString * activityDescription;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) Master *master;
@end

@interface ActivityStory (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addLikesObject:(Like *)value;
- (void)removeLikesObject:(Like *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

@end
