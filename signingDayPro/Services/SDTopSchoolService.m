//
//  SDTopSchoolService.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDTopSchoolService.h"
#import "TopSchool.h"
#import "Team.h"
#import "Player.h"
#import "User.h"
#import "SDAPIClient.h"
#import "NSDictionary+NullConverver.h"
#import "SDProfileService.h"
#import <AFNetworking.h>

@implementation SDTopSchoolService

#pragma mark - Get Offers for User
+ (void)getTopSchoolsForUser:(User *)user
             completionBlock:(void (^)(void))completionBlock
                failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"sd/topteams.json"
                             parameters:[NSDictionary dictionaryWithObject:[user.identifier stringValue] forKey:@"UserId"]
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    if ([responseObject valueForKey:@"TopTeams"] && ![[responseObject valueForKey:@"TopTeams"] isEqual:[NSNull null]]) {
                                        
                                        NSArray *dataArray = [responseObject valueForKey:@"TopTeams"];
                                        if (user.thePlayer.topSchools)
                                            [user.thePlayer removeTopSchools:user.thePlayer.topSchools];
                                        for (NSDictionary *unformatedDictionary in dataArray) {
                                            NSDictionary *dictionary = [unformatedDictionary dictionaryByReplacingNullsWithStrings];
                                            
                                            NSNumber *teamIdentifier = [NSNumber numberWithInt:[[dictionary valueForKey:@"TeamID"] intValue]];
                                            User *teamUser = [User MR_findFirstByAttribute:@"identifier"
                                                                                 withValue:teamIdentifier
                                                                                 inContext:context];
                                            if (!teamUser) {
                                                teamUser = [User MR_createInContext:context];
                                                teamUser.identifier = teamIdentifier;
                                            }
                                            if (!teamUser.theTeam)
                                                teamUser.theTeam = [Team MR_createInContext:context];
                                            
                                            teamUser.userTypeId = [NSNumber numberWithInt:SDUserTypeTeam];
                                            teamUser.avatarUrl = [dictionary valueForKey:@"TeamAvatarUrl"];
                                            
                                            teamUser.name = [dictionary valueForKey:@"TeamInstitution"];
                                            
                                            TopSchool *topSchool = [TopSchool MR_createInContext:context];
                                            topSchool.theTeam = teamUser.theTeam;
                                            topSchool.interest = [NSNumber numberWithInt:[[dictionary valueForKey:@"Interest"] intValue]];
                                            topSchool.rank = [NSNumber numberWithInt:[[dictionary valueForKey:@"Rank"] intValue]];
                                            
                                            if ([[[dictionary valueForKey:@"IsCommited"] class] isSubclassOfClass:[NSNumber class]])
                                                topSchool.hasOfferFromTeam = [NSNumber numberWithBool:YES];
                                            else if ([[[dictionary valueForKey:@"IsCommited"] class] isSubclassOfClass:[NSString class]])
                                                topSchool.hasOfferFromTeam = [NSNumber numberWithBool:NO];
                                            
                                            [user.thePlayer addTopSchoolsObject:topSchool];
                                        }
                                        
                                        [context MR_saveOnlySelfAndWait];
                                    }
                                    
                                    if (completionBlock)
                                        completionBlock();
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)startHTTPRequestOperationWithURLString:(NSString *)URLString
                         operationSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))operationSuccessBlock
                         operationFailureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))operationFailureBlock
{
    URLString = [[[URLString stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"$" withString:@"%24"] stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operationSuccessBlock)
            operationSuccessBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operationFailureBlock)
            operationFailureBlock(operation, error);
    }];
    [operation start];
}

@end
