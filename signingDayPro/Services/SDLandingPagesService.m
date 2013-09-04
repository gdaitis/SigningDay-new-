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
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/PlayersDto?$orderby=BaseScore desc&skip=%d&$top=%d&$format=json", kSDBaseSigningDayURLString, pageBeginIndex, top];
    
    [self startPlayersHTTPRequestOperationWithURLString:urlString
                                           successBlock:successBlock
                                           failureBlock:failureBlock];
    
}

+ (void)searchForPlayersWithString:(NSString *)searchString
                      successBlock:(void (^)(void))successBlock
                      failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/PlayersDto?$filter=substringof('%@',DisplayName)&$format=json", kSDBaseSigningDayURLString, searchString];
    [self startPlayersHTTPRequestOperationWithURLString:urlString
                                           successBlock:successBlock
                                           failureBlock:failureBlock];
}

+ (void)createPlayersFromResponseDataObject:(id)responseObject
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                         options:kNilOptions
                                                           error:nil];
    NSArray *resultsArray = [JSON valueForKey:@"d"];
    for (NSDictionary *userDictionaryWithNulls in resultsArray) {
        NSDictionary *userDictionary = [userDictionaryWithNulls dictionaryByReplacingNullsWithStrings];
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
    }
    [context MR_saveOnlySelfAndWait];
}

+ (void)startPlayersHTTPRequestOperationWithURLString:(NSString *)URLString
                                         successBlock:(void (^)(void))successBlock
                                         failureBlock:(void (^)(void))failureBlock
{
    URLString = [[[URLString stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"$" withString:@"%24"] stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self createPlayersFromResponseDataObject:responseObject];
        if (successBlock)
            successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock)
            failureBlock();
    }];
    [operation start];
}

#pragma mark - Teams

#pragma mark - HighSchools

@end
