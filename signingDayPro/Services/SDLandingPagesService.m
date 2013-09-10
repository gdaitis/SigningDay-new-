//
//  SDLandingPagesService.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDLandingPagesService.h"
#import "SDAPIClient.h"
#import "AFNetworking.h"
#import "NSDictionary+NullConverver.h"
#import "User.h"
#import "Player.h"
#import "HighSchool.h"
#import "NSString+HTML.h"
#import "SDProfileService.h"

@implementation SDLandingPagesService

#pragma mark - Players

+ (void)getPlayersOrderedByDescendingBaseScoreFrom:(NSInteger)pageBeginIndex
                                                to:(NSInteger)pageEndIndex
                                      successBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock
{
    if (pageBeginIndex > pageEndIndex) {
        NSLog(@"Cannot load players: end index is lower that begin index");
        return;
    }
    int top = pageEndIndex - pageBeginIndex;
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/PlayersDto?$orderby=BaseScore desc&$skip=%d&$top=%d&$format=json", kSDBaseSigningDayURLString, pageBeginIndex, top];
    
    [self startPlayersHTTPRequestOperationWithURLString:urlString
                                           successBlock:successBlock
                                           failureBlock:failureBlock];
    
}

+ (void)searchForPlayersWithString:(NSString *)searchString
                      successBlock:(void (^)(void))successBlock
                      failureBlock:(void (^)(void))failureBlock
{
    [self searchForPlayersWithNameString:searchString
                   stateCodeStringsArray:nil
                  classYearsStringsArray:nil
                    positionStringsArray:nil
                            successBlock:successBlock
                            failureBlock:failureBlock];
}

+ (void)searchForPlayersWithNameString:(NSString *)searchString
                 stateCodeStringsArray:(NSArray *)statesArray
                classYearsStringsArray:(NSArray *)classesArray
                  positionStringsArray:(NSArray *)positionsArray
                          successBlock:(void (^)(void))successBlock
                          failureBlock:(void (^)(void))failureBlock
{
    NSString *statesString = nil;
    NSString *classesString = nil;
    NSString *positionsString = nil;
    NSString *searchRequestString = nil;
    NSMutableArray *requestStringsArray = [[NSMutableArray alloc] init];

    if (searchString) {
        searchRequestString = [NSString stringWithFormat:@"substringof('%@',DisplayName)", searchString];
        [requestStringsArray addObject:searchRequestString];
    }
    if (statesArray) {
        statesString = @"";
        for (int i = 0; i < [statesArray count]; i++) {
            NSString *stateCodeString = [statesArray objectAtIndex:i];
            statesString = [statesString stringByAppendingFormat:@"PlayerStateCode eq '%@' ", stateCodeString];
            if (i != ([statesArray count] - 1))
                statesString = [statesString stringByAppendingFormat:@"or "];
        }
        [requestStringsArray addObject:statesString];
    }
    if (classesArray) {
        classesString = @"";
        for (int i = 0; i < [classesArray count]; i++) {
            NSString *classString = [statesArray objectAtIndex:i];
            classesString = [classesString stringByAppendingFormat:@"Class eq %@ ", classString];
            if (i != ([classesArray count] - 1))
                classesString = [classesString stringByAppendingFormat:@"or "];
        }
        [requestStringsArray addObject:classesString];
    }
    if (positionsArray) {
        positionsString = @"";
        for (int i = 0; i < [positionsArray count]; i++) {
            NSString *positionString = [statesArray objectAtIndex:i];
            positionsString = [positionsString stringByAppendingFormat:@"Position eq '%@' ", positionString];
            if (i != ([positionsArray count] - 1))
                positionsString = [positionsString stringByAppendingFormat:@"or "];
        }
        [requestStringsArray addObject:positionsString];
    }
    
    NSString *filterString = @"";
    for (int i = 0; i < [requestStringsArray count]; i++) {
        NSString *paramsString = [requestStringsArray objectAtIndex:i];
        filterString = [filterString stringByAppendingFormat:@"(%@) ", paramsString];
        if (i != ([requestStringsArray count] - 1))
            filterString = [filterString stringByAppendingFormat:@"and "];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/PlayersDto?$orderby=DisplayName asc&$format=json&$filter=(%@)", kSDBaseSigningDayURLString, filterString];
    
    [self startPlayersHTTPRequestOperationWithURLString:urlString
                                           successBlock:successBlock
                                           failureBlock:failureBlock];
}

+ (void)startPlayersHTTPRequestOperationWithURLString:(NSString *)URLString
                                         successBlock:(void (^)(void))successBlock
                                         failureBlock:(void (^)(void))failureBlock
{
    [self startHTTPRequestOperationWithURLString:URLString
                           operationSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                               [self createUsersFromResponseObject:responseObject
                                         withBlockForSpecificTypes:^(NSDictionary *userDictionary, NSManagedObjectContext *context) {
                                             NSNumber *identifier = [NSNumber numberWithInt:[[userDictionary valueForKey:@"UserId"] intValue]];
                                             User *user = [User MR_findFirstByAttribute:@"identifier"
                                                                              withValue:identifier
                                                                              inContext:context];
                                             if (!user) {
                                                 user = [User MR_createInContext:context];
                                                 user.identifier = identifier;
                                             }
                                             user.name = [userDictionary valueForKey:@"DisplayName"];
                                             user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
                                             user.userTypeId = [NSNumber numberWithInt:SDUserTypePlayer];
                                             if (!user.thePlayer)
                                                 user.thePlayer = [Player MR_createInContext:context];
                                             user.thePlayer.positionRanking = [NSNumber numberWithInt:[[userDictionary valueForKey:@"PositionRank"] intValue]];
                                             user.thePlayer.stateRanking = [NSNumber numberWithInt:[[userDictionary valueForKey:@"StateRank"] intValue]];
                                             user.thePlayer.height = [NSNumber numberWithInt:[[userDictionary valueForKey:@"Height"] intValue]];
                                             user.thePlayer.weight = [NSNumber numberWithInt:[[userDictionary valueForKey:@"Weight"] intValue]];
                                             user.thePlayer.userClass = [NSString stringWithFormat:@"%d", [[userDictionary valueForKey:@"Class"] intValue]];
                                             user.thePlayer.position = [userDictionary valueForKey:@"Position"];
                                             user.thePlayer.baseScore = [NSNumber numberWithFloat:[[userDictionary valueForKey:@"BaseScore"] floatValue]];
                                             user.thePlayer.nationalRanking = [NSNumber numberWithInt:[[userDictionary valueForKey:@"NationalRank"] intValue]];
                                             user.thePlayer.starsCount = [NSNumber numberWithInt:[[userDictionary valueForKey:@"Stars"] intValue]];
                                             user.accountVerified = [NSNumber numberWithBool:[[userDictionary valueForKey:@"IsVerified"] boolValue]];
                                             
                                             NSNumber *highSchoolIdentifier = [NSNumber numberWithInt:[[userDictionary valueForKey:@"HighSchoolID"] intValue]];
                                             User *highSchoolUser = [User MR_findFirstByAttribute:@"identifier"
                                                                                        withValue:highSchoolIdentifier
                                                                                        inContext:context];
                                             if (!highSchoolUser) {
                                                 highSchoolUser = [User MR_createInContext:context];
                                                 highSchoolUser.identifier = highSchoolIdentifier;
                                             }
                                             highSchoolUser.name = [userDictionary valueForKey:@"HighSchoolName"];
                                             if (!highSchoolUser.theHighSchool)
                                                 highSchoolUser.theHighSchool = [HighSchool MR_createInContext:context];
                                             highSchoolUser.theHighSchool.mascot = [userDictionary valueForKey:@"HighSchoolMascot"];
                                             
                                             user.thePlayer.highSchool = highSchoolUser.theHighSchool;
                                         }];
                               if (successBlock)
                                   successBlock();
                           } operationFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                               if (failureBlock)
                                   failureBlock();
                           }];
}

#pragma mark - Teams

+ (void)getTeamsOrderedByDescendingTotalScoreFrom:(NSInteger)pageBeginIndex
                                               to:(NSInteger)pageEndIndex
                                     successBlock:(void (^)(void))successBlock
                                     failureBlock:(void (^)(void))failureBlock
{
    if (pageBeginIndex > pageEndIndex) {
        NSLog(@"Cannot load players: end index is lower that begin index");
        return;
    }
    int top = pageEndIndex - pageBeginIndex;
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/TeamsView?$orderby=TotalScore desc&$skip=%d&$top=%d&$format=json", kSDBaseSigningDayURLString, pageBeginIndex, top]; // <- TotalScore??
    
    [self startTeamsHTTPRequestOperationWithURLString:urlString
                                         successBlock:successBlock
                                         failureBlock:failureBlock];
    
}

+ (void)startTeamsHTTPRequestOperationWithURLString:(NSString *)URLString
                                       successBlock:(void (^)(void))successBlock
                                       failureBlock:(void (^)(void))failureBlock
{

}

#pragma mark - HighSchools

#pragma mark - Common methods

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

+ (void)createUsersFromResponseObject:(id)responseObject
            withBlockForSpecificTypes:(void (^)(NSDictionary *userDictionary, NSManagedObjectContext *context))specificTypeOfUserCreationBlock
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                         options:kNilOptions
                                                           error:nil];
    NSArray *resultsArray = [JSON valueForKey:@"d"];
    for (NSDictionary *userDictionaryWithNulls in resultsArray) {
        NSDictionary *userDictionary = [userDictionaryWithNulls dictionaryByReplacingNullsWithStrings];
        if (specificTypeOfUserCreationBlock)
            specificTypeOfUserCreationBlock(userDictionary, context);
    }
    [context MR_saveOnlySelfAndWait];
}

@end
