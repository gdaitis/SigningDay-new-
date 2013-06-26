//
//  SDActivityFeedService.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedService.h"
#import "SDAPIClient.h"
#import "ActivityStory.h"
#import "User.h"
#import "Like.h"
#import "Comment.h"
#import "HTMLParser.h"

@interface SDActivityFeedService ()

+ (void)createCommentFromDictionary:(NSDictionary *)commentDictionary;
+ (void)createLikeFromDictionary:(NSDictionary *)likeDictionary;

@end

@implementation SDActivityFeedService

+ (void)getActivityStoriesWithSuccessBlock:(void (^)(void))successBlock
                              failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"stories.json"
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];
                                    
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSArray *activityStories = [JSON valueForKey:@"ActivityStories"];
                                    for (int i = 0; i < [activityStories count]; i++) {
                                        NSDictionary *activityStoryDictionary = [activityStories objectAtIndex:i];
                                        
                                        NSString *identifier = [activityStoryDictionary valueForKey:@"Id"];
                                        ActivityStory *activityStory = [ActivityStory MR_findFirstByAttribute:@"identifier"
                                                                                                    withValue:identifier
                                                                                                    inContext:context];
                                        if (!activityStory) {
                                            activityStory = [ActivityStory MR_createInContext:context];
                                            activityStory.identifier = identifier;
                                        }
                                        
                                        NSString *previewHtmlString = [activityStoryDictionary valueForKey:@"PreviewHtml"];
                                        NSError *htmlError = nil;
                                        HTMLParser *parser = [[HTMLParser alloc] initWithString:previewHtmlString
                                                                                          error:&htmlError];
                                        if (htmlError) {
                                            NSLog(@"Error: %@", htmlError);
                                        } else {
                                            HTMLNode *bodyNode = [parser body];
                                            
                                            NSArray *spanNodes = [bodyNode findChildTags:@"span"];
                                            for (HTMLNode *spanNode in spanNodes) {
                                                if ([[spanNode getAttributeNamed:@"class"] isEqualToString:@"activity-title"]) {
                                                    activityStory.activityTitle = [spanNode allContents];
                                                }
                                            }
                                            
                                            NSArray *divNodes = [bodyNode findChildTags:@"div"];
                                            for (HTMLNode *divNode in divNodes) {
                                                if ([[divNode getAttributeNamed:@"class"] isEqualToString:@"activity-description"]) {
                                                    activityStory.activityDescription = [divNode allContents];
                                                }
                                                if ([[divNode getAttributeNamed:@"class"] isEqualToString:@"activity-content"]) {
                                                    activityStory.activityDescription = [divNode allContents];
                                                }
                                            }
                                            
                                            NSArray *imgNodes = [bodyNode findChildTags:@"img"];
                                            for (HTMLNode *imgNode in imgNodes) {
                                                activityStory.imagePath = [imgNode getAttributeNamed:@"src"];
                                            }
                                        }
                                        
                                        NSString *activityStoryTypeId = [activityStoryDictionary valueForKey:@"StoryTypeId"];
                                        activityStory.storyTypeId = activityStoryTypeId;
                                        
                                        NSString *contentId = [[activityStoryDictionary valueForKey:@"Content"] valueForKey:@"ContentId"];
                                        activityStory.contentId = contentId;
                                        
                                        NSString *contentTypeId = [[activityStoryDictionary valueForKey:@"Content"] valueForKey:@"ContentTypeId"];
                                        activityStory.contentTypeId = contentTypeId;
                                        
                                        NSString *createdDateString = [[activityStoryDictionary objectForKey:@"CreatedDate"] stringByDeletingPathExtension];
                                        NSString *lastUpdateDateString = [[activityStoryDictionary objectForKey:@"LastUpdate"] stringByDeletingPathExtension];
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                        NSDate *createdDate = [dateFormatter dateFromString:createdDateString];
                                        activityStory.createdDate = createdDate;
                                        NSDate *lastUpdateDate = [dateFormatter dateFromString:lastUpdateDateString];
                                        activityStory.lastUpdateDate = lastUpdateDate;
                                        
                                        NSDictionary *authorDictionary = [[activityStoryDictionary valueForKey:@"Content"] valueForKey:@"CreatedByUser"];
                                        NSNumber *authorIdentifier = [NSNumber numberWithInt:[[authorDictionary valueForKey:@"Id"] intValue]];
                                        User *author = [User MR_findFirstByAttribute:@"identifier" withValue:authorIdentifier];
                                        if (!author) {
                                            author = [User MR_createInContext:context];
                                            author.identifier = authorIdentifier;
                                        }
                                        author.username = [authorDictionary valueForKey:@"Username"];
                                        author.avatarUrl = [authorDictionary valueForKey:@"AvatarUrl"];
                                        author.name = [authorDictionary valueForKey:@"DisplayName"];
                                        
                                        activityStory.author = author;
                                        
                                        NSMutableURLRequest *likesRequest = [[SDAPIClient sharedClient] requestWithMethod:@"GET"
                                                                                                                path:@"likes.json"
                                                                                                          parameters:@{@"ContentId": activityStory.contentId}];
                                        AFHTTPRequestOperation *likesOperation = [[SDAPIClient sharedClient] HTTPRequestOperationWithRequest:likesRequest
                                                                                                                                     success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                                                                                         NSArray *likesArray = [JSON valueForKey:@"Likes"];
                                                                                                                                         for (NSDictionary *likeDictionary in likesArray) {
                                                                                                                                             [self createLikeFromDictionary:likeDictionary];
                                                                                                                                         }
                                                                                                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                                                         NSLog(@"Likes parse failed");
                                                                                                                                     }];
                                        [operationsArray addObject:likesOperation];
                                        
                                        NSMutableURLRequest *commentsRequest = [[SDAPIClient sharedClient] requestWithMethod:@"GET"
                                                                                                                        path:@"comments.json"
                                                                                                                  parameters:@{@"ContentId":activityStory.contentId}];
                                        AFHTTPRequestOperation *commentsOperation = [[SDAPIClient sharedClient] HTTPRequestOperationWithRequest:commentsRequest
                                                                                                                                        success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                                                                                            NSArray *commentsArray = [JSON valueForKey:@"Comments"];
                                                                                                                                            for (NSDictionary *commentDictionary in commentsArray) {
                                                                                                                                                [self createCommentFromDictionary:commentDictionary];
                                                                                                                                            }
                                                                                                                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                                                            NSLog(@"Comments parse failed");
                                                                                                                                        }];
                                        [operationsArray addObject:commentsOperation];
                                    }
                                    [context MR_save];
                                    
                                    [[SDAPIClient sharedClient] enqueueBatchOfHTTPRequestOperations:operationsArray
                                                                                      progressBlock:nil
                                                                                    completionBlock:^(NSArray *operations) {
                                                                                          successBlock();
                                                                                      }];
                                    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    
}

+ (void)likeActivityStory:(ActivityStory *)activityStory
             successBlock:(void (^)(void))successBlock
             failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] postPath:@"likes.json"
                              parameters:@{@"ContentId":activityStory.contentId, @"ContentTypeId":activityStory.contentTypeId}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSDictionary *likeDictionary = [JSON valueForKey:@"Like"];
                                     [self createLikeFromDictionary:likeDictionary];
                                     successBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     failureBlock();
                                 }];
}

+ (void)unlikeActivityStory:(ActivityStory *)activityStory
               successBlock:(void (^)(void))successBlock
               failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] deletePath:@"like.json"
                                parameters:@{@"ContentId":activityStory.contentId}
                                   success:^(AFHTTPRequestOperation *operation, id JSON) {
                                       NSManagedObjectContext *deletionContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                       [activityStory MR_deleteEntity];
                                       [deletionContext MR_save];
                                       successBlock();
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       failureBlock();
                                   }];
}

+ (void)addCommentToActivityStory:(ActivityStory *)activityStory
                             text:(NSString *)commentText
                     successBlock:(void (^)(void))successBlock
                     failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] postPath:@"comments.json"
                              parameters:@{@"ContentId":activityStory.contentId, @"ContentTypeId":activityStory.contentTypeId, @"Body":commentText}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSDictionary *commentDictionary = [JSON valueForKey:@"Comment"];
                                     [self createCommentFromDictionary:commentDictionary];
                                     successBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     failureBlock();
                                 }];
}

+ (void)removeComment:(Comment *)comment
         successBlock:(void (^)(void))successBlock
         failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"comments/%@", comment.commentId];
    [[SDAPIClient sharedClient] deletePath:path
                                parameters:@{@"CommentId":comment.commentId}
                                   success:^(AFHTTPRequestOperation *operation, id JSON) {
                                       NSManagedObjectContext *deletionContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                       [comment MR_deleteEntity];
                                       [deletionContext MR_save];
                                       successBlock();
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       failureBlock();
                                   }];
}

#pragma mark - Private methods

+ (void)createCommentFromDictionary:(NSDictionary *)commentDictionary
{
    NSString *commentId = [commentDictionary valueForKey:@"CommentId"];
    NSString *contentId = [[commentDictionary valueForKey:@"Content"] valueForKey:@"ContentId"];
    NSManagedObjectContext *commentsContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Comment *comment = [Comment MR_findFirstByAttribute:@"commentId"
                                              withValue:commentId
                                              inContext:commentsContext];
    if (!comment) {
        comment = [Comment MR_createInContext:commentsContext];
        
        comment.commentId = commentId;
        
        NSString *createdDateString = [[commentDictionary objectForKey:@"CreatedDate"] stringByDeletingPathExtension];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *createdDate = [dateFormatter dateFromString:createdDateString];
        comment.createdDate = createdDate;
        
        ActivityStory *activityStory = [ActivityStory MR_findFirstByAttribute:@"contentId"
                                                                    withValue:contentId
                                                                    inContext:commentsContext];
        comment.activityStory = activityStory;
    }
    
    NSString *commentBody = [commentDictionary valueForKey:@"Body"];
    comment.body = commentBody;
    
    NSDictionary *userDictionary = [commentDictionary valueForKey:@"User"];
    NSNumber *identifier = [NSNumber numberWithInt:[[userDictionary valueForKey:@"Id"] intValue]];
    User *user = [User MR_findFirstByAttribute:@"identifier"
                                     withValue:identifier
                                     inContext:commentsContext];
    if (!user) {
        user = [User MR_createInContext:commentsContext];
        user.identifier = identifier;
    }
    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
    user.username = [userDictionary valueForKey:@"Username"];
    user.name = [userDictionary valueForKey:@"DisplayName"];
    comment.user = user;
    
    NSString *updatedDateString = [[commentDictionary objectForKey:@"UpdatedDate"] stringByDeletingPathExtension];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSDate *updatedDate = [dateFormatter dateFromString:updatedDateString];
    comment.updatedDate = updatedDate;
    
    [commentsContext MR_save];
}

+ (void)createLikeFromDictionary:(NSDictionary *)likeDictionary
{
    NSManagedObjectContext *likesContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSString *contentId = [[likeDictionary valueForKey:@"Content"] valueForKey:@"ContentId"];
    NSPredicate *activityStoryPredicate = [NSPredicate predicateWithFormat:@"activityStory.contentId == %@", contentId];
    
    NSNumber *identifier = [NSNumber numberWithInt:[[[likeDictionary valueForKey:@"User"] valueForKey:@"Id"] intValue]];
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"user.identifier == %@", identifier];
    
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[activityStoryPredicate, userPredicate]];
    Like *like = [Like MR_findFirstWithPredicate:andPredicate
                                       inContext:likesContext];
    if (!like) {
        like = [Like MR_createInContext:likesContext];
        
        ActivityStory *activityStory = [ActivityStory MR_findFirstByAttribute:@"contentId"
                                                                    withValue:contentId
                                                                    inContext:likesContext];
        like.activityStory = activityStory;
        
        NSString *createdDateString = [[likeDictionary objectForKey:@"CreatedDate"] stringByDeletingPathExtension];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *createdDate = [dateFormatter dateFromString:createdDateString];
        like.createdDate = createdDate;
    }
    NSDictionary *userDictionary = [likeDictionary valueForKey:@"User"];
    User *user = [User MR_findFirstByAttribute:@"identifier"
                                     withValue:identifier
                                     inContext:likesContext];
    if (!user) {
        user = [User MR_createInContext:likesContext];
        user.identifier = identifier;
    }
    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
    user.username = [userDictionary valueForKey:@"Username"];
    user.name = [userDictionary valueForKey:@"DisplayName"];
    like.user = user;
    [likesContext MR_save];
}

@end