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
#import "NSString+HTML.h"
#import "SDProfileService.h"
#import "User.h"
#import "Player.h"
#import "HighSchool.h"
#import "Team.h"
#import "Conference.h"
#import "State.h"

@interface User (BasicUserInfoParsing)

+ (User *)getUserWithBasicUserInfoFromUserDictionary:(NSDictionary *)userDictionary
                                          andContext:(NSManagedObjectContext *)context;

@end

@implementation User (BasicUserInfoParsing)

+ (User *)getUserWithBasicUserInfoFromUserDictionary:(NSDictionary *)userDictionary
                                          andContext:(NSManagedObjectContext *)context
{
    NSString *userIDString = [userDictionary valueForKey:@"UserId"];
    if (userIDString)
        exit(0);
    NSNumber *identifier = [NSNumber numberWithInt:[[userDictionary valueForKey:@"UserID"] intValue]];
    User *user = [User MR_findFirstByAttribute:@"identifier"
                                     withValue:identifier
                                     inContext:context];
    if (!user) {
        user = [User MR_createInContext:context];
        user.identifier = identifier;
    }
    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
    user.accountVerified = [NSNumber numberWithBool:[[userDictionary valueForKey:@"IsVerified"] boolValue]];
    
    return user;
}

@end

@implementation SDLandingPagesService

#pragma mark - Players

+ (void)getPlayersOrderedByDescendingBaseScoreFrom:(NSInteger)pageBeginIndex
                                                to:(NSInteger)pageEndIndex
                                          forClass:(NSString *)classString
                                      successBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock
{
    if (pageBeginIndex > pageEndIndex) {
        NSLog(@"Cannot load players: end index is lower that begin index");
        return;
    }
    int top = pageEndIndex - pageBeginIndex;
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/PlayersDto?$orderby=BaseScore desc,Stars desc,DisplayName asc&$skip=%d&$top=%d&$format=json&$filter=(Class eq %@)", kSDBaseSigningDayURLString, pageBeginIndex, top, classString];
    
    //    &$DisplayBaseScore=true
    NSLog(@"urlString = %@",urlString);
    
    [self startPlayersHTTPRequestOperationWithURLString:urlString
                                           successBlock:successBlock
                                           failureBlock:failureBlock];
    
}

+ (void)searchForPlayersWithNameString:(NSString *)searchString
                                  from:(NSInteger)pageBeginIndex
                                    to:(NSInteger)pageEndIndex
                 stateCodeStringsArray:(NSArray *)statesArray
                classYearsStringsArray:(NSArray *)classesArray
                  positionStringsArray:(NSArray *)positionsArray
                     sortedBy:(NSString *)sortOption
                          successBlock:(void (^)(void))successBlock
                          failureBlock:(void (^)(void))failureBlock
{
    NSMutableArray *requestStringsArray = [[NSMutableArray alloc] init];

    if (searchString) {
        NSString *searchRequestString = [NSString stringWithFormat:@"substringof('%@',DisplayName)", searchString];
        [requestStringsArray addObject:searchRequestString];
    }
    if (statesArray) {
        NSString *statesString = [self makeRequestsStringFromRequestsArray:statesArray
                                              withUrlEntityNameToBeEqualTo:@"PlayerStateCode"
                                                appendingWithLogicalString:@"or "];
        [requestStringsArray addObject:statesString];
    }
    if (classesArray) {
        NSString *classesString = [self makeRequestsStringFromRequestsArray:classesArray
                                               withUrlEntityNameToBeEqualTo:@"Class"
                                                 appendingWithLogicalString:@"or "];
        [requestStringsArray addObject:classesString];
    }
    if (positionsArray) {
        NSString *positionsString = [self makeRequestsStringFromRequestsArray:positionsArray
                                                 withUrlEntityNameToBeEqualTo:@"Position"
                                                   appendingWithLogicalString:@"or "];
        [requestStringsArray addObject:positionsString];
    }
    NSString *filterString = [self makeFilterStringFromRequestStringsArray:requestStringsArray];
    int top = pageEndIndex - pageBeginIndex;
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/PlayersDto?$orderby=%@&$format=json&$skip=%d&$top=%d&$filter=(%@)", kSDBaseSigningDayURLString, sortOption,pageBeginIndex, top, filterString];
    
//    &$DisplayBaseScore=true
    NSLog(@"urlString = %@",urlString);
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
                               
                               NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                               
                               [self createUsersFromResponseObject:responseObject
                                                       withContext:context
                                         withBlockForSpecificTypes:^(NSDictionary *userDictionary, NSManagedObjectContext *context, User *user) {
                                             userDictionary = [userDictionary dictionaryByReplacingNullsWithStrings];
                                             user.userTypeId = [NSNumber numberWithInt:SDUserTypePlayer];
                                             user.name = [userDictionary valueForKey:@"DisplayName"];
                                             
                                             NSLog(@"Downloaded Player: %@",user.name);
                                             
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
                                             
                                             
                                             //assign a state to user (this is needed for filtering in landingpagecontrollers)
                                             NSString *code = [userDictionary valueForKey:@"PlayerStateCode"];
                                             State *state = [State MR_findFirstByAttribute:@"code"
                                                                                 withValue:code
                                                                                 inContext:context];
                                             if (!state) {
                                                 state = [State MR_createInContext:context];
                                                 state.code = code;
                                             }
                                             user.state = state;
                                             
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
                               [context MR_saveOnlySelfAndWait];
                               if (successBlock)
                                   successBlock();
                           } operationFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                               if (failureBlock)
                                   failureBlock();
                           }];
}

#pragma mark - Teams

+ (void)getTeamsOrderedByDescendingTotalScoreWithPageNumber:(NSInteger)pageNumber
                                                   pageSize:(NSInteger)pageSize
                                                classString:(NSString *)classString
                                         conferenceIdString:(NSString *)conferenceIdString
                                               successBlock:(void (^)(void))successBlock
                                               failureBlock:(void (^)(void))failureBlock
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@services/signingday.svc/Teams?year=%@&page=%i&count=%i", kSDBaseSigningDayURLString, classString, pageNumber, pageSize];

    if (conferenceIdString)
        [urlString appendFormat:@"&conference=%@",conferenceIdString];
    [urlString appendString:@"&$format=json"];
    
    
    [self startTeamsHTTPRequestOperationWithURLString:urlString
                                          classString:classString
                                         successBlock:successBlock
                                         failureBlock:failureBlock];
}

+ (void)searchForTeamsWithNameString:(NSString *)searchString
                  conferenceIDString:(NSString *)conferenceString
                         classString:(NSString *)classString
                        successBlock:(void (^)(void))successBlock
                        failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/Teams?year=%@", kSDBaseSigningDayURLString, classString];
    
    if (conferenceString)
        urlString = [urlString stringByAppendingFormat:@"&conference=%@",conferenceString];
    if (searchString.length > 2)
    {
        urlString = [urlString stringByAppendingFormat:@"&$filter=(substringof(tolower('%@'),tolower(DisplayName)))", searchString];
    }
    urlString = [urlString stringByAppendingString:@"&$format=json"];
    
    [self startTeamsHTTPRequestOperationWithURLString:urlString
                                          classString:classString
                                         successBlock:successBlock
                                         failureBlock:failureBlock];
}

+ (void)startTeamsHTTPRequestOperationWithURLString:(NSString *)URLString
                                        classString:(NSString *)classString
                                       successBlock:(void (^)(void))successBlock
                                       failureBlock:(void (^)(void))failureBlock
{
    [self startHTTPRequestOperationWithURLString:URLString
                           operationSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                               
                               NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                               
                               [self createUsersFromResponseObject:responseObject
                                                       withContext:context
                                         withBlockForSpecificTypes:^(NSDictionary *userDictionary, NSManagedObjectContext *context, User *user) {
                                             userDictionary = [userDictionary dictionaryByReplacingNullsWithStrings];
                                             user.userTypeId = [NSNumber numberWithInt:SDUserTypeTeam];
                                             user.name = [userDictionary valueForKey:@"DisplayName"];
                                             if (!user.theTeam)
                                                 user.theTeam = [Team MR_createInContext:context];
                                             user.theTeam.teamName =[userDictionary valueForKey:@"TeamName"];
                                             user.theTeam.conferenceId = [NSNumber numberWithInt:[[userDictionary valueForKey:@"ConferenceID"] intValue]];
                                             user.theTeam.universityName = [userDictionary valueForKey:@"FullInstitutionName"];
                                             user.theTeam.location = [userDictionary valueForKey:@"TeamCity"];
                                             user.theTeam.stateCode = [userDictionary valueForKey:@"TeamStateCode"];
                                             user.theTeam.numberOfCommits = [NSNumber numberWithInt:[[userDictionary valueForKey:@"Commits"] intValue]];
                                             user.theTeam.totalScore = [NSNumber numberWithFloat:[[userDictionary valueForKey:@"Total"] floatValue]];
                                             user.theTeam.teamClass = classString;  //need to save year(class) for team for proper coredata sorting and paging
                                         }];
                               [context MR_saveOnlySelfAndWait];
                               if (successBlock)
                                   successBlock();
                           } operationFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                               if (failureBlock)
                                   failureBlock();
                           }];
}

#pragma mark - HighSchools

+ (void)getAllHighSchoolsForAllStatesForYearString:(NSString *)yearString
                                        pageNumber:(NSInteger)pageNumber
                                          pageSize:(NSInteger)pageSize
                                      successBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/HighSchools?year=%@&count=%d&page=%d&$format=json", kSDBaseSigningDayURLString, yearString, pageSize, pageNumber];
    NSLog(@"all states urlString = %@",urlString);
    
    [self startHighSchoolsHTTPRequestOperationWithURLString:urlString
                                               successBlock:successBlock
                                               failureBlock:failureBlock];
}

+ (void)getAllHighSchoolsForState:(NSString *)stateCode
                    ForYearString:(NSString *)yearString
                                        pageNumber:(NSInteger)pageNumber
                                          pageSize:(NSInteger)pageSize
                                      successBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/HighSchools?year=%@&count=%d&page=%d&state='%@'&$format=json", kSDBaseSigningDayURLString, yearString, pageSize, pageNumber,stateCode];
    NSLog(@"urlString = %@",urlString);
    
    [self startHighSchoolsHTTPRequestOperationWithURLString:urlString
                                               successBlock:successBlock
                                               failureBlock:failureBlock];
}

+ (void)searchForHighSchoolsInAllStatesWithNameString:(NSString *)searchString
                                           yearString:(NSString *)yearString
                                         successBlock:(void (^)(void))successBlock
                                         failureBlock:(void (^)(void))failureBlock
{
    [self searchForHighSchoolsWithNameString:searchString
                                  yearString:yearString
                       stateCodeStringsArray:nil
                                successBlock:successBlock
                                failureBlock:failureBlock];
}

+ (void)searchForHighSchoolsWithNameString:(NSString *)searchString
                                yearString:(NSString *)yearString
                     stateCodeStringsArray:(NSArray *)statesArray
                              successBlock:(void (^)(void))successBlock
                              failureBlock:(void (^)(void))failureBlock
{
    NSMutableArray *requestStringsArray = [[NSMutableArray alloc] init];
    
    if (searchString) {
        NSString *searchRequestString = [NSString stringWithFormat:@"substringof(tolower('%@'),tolower(DisplayName))", searchString];
        [requestStringsArray addObject:searchRequestString];
    }
    if (statesArray) {
        NSString *statesString = [self makeRequestsStringFromRequestsArray:statesArray
                                              withUrlEntityNameToBeEqualTo:@"HighSchoolState"
                                                appendingWithLogicalString:@"or "];
        [requestStringsArray addObject:statesString];
    }
    NSString *filterString = [self makeFilterStringFromRequestStringsArray:requestStringsArray];
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/HighSchools?year=%@&$format=json&$filter=(%@)", kSDBaseSigningDayURLString, yearString, filterString];
    
    [self startHighSchoolsHTTPRequestOperationWithURLString:urlString
                                           successBlock:successBlock
                                           failureBlock:failureBlock];
}

+ (void)startHighSchoolsHTTPRequestOperationWithURLString:(NSString *)URLString
                                             successBlock:(void (^)(void))successBlock
                                             failureBlock:(void (^)(void))failureBlock
{
    [self startHTTPRequestOperationWithURLString:URLString
                           operationSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                               
                               NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                               
                               [self createUsersFromResponseObject:responseObject
                                                       withContext:context
                                         withBlockForSpecificTypes:^(NSDictionary *userDictionary, NSManagedObjectContext *context, User *user) {
                                             user.userTypeId = [NSNumber numberWithInt:SDUserTypeHighSchool];
                                             user.name = [userDictionary valueForKey:@"DisplayName"];
                                             if (!user.theHighSchool)
                                                 user.theHighSchool = [HighSchool MR_createInContext:context];
                                             user.theHighSchool.totalProspects = [userDictionary valueForKey:@"CurrentProspects"];
                                             user.theHighSchool.city = [userDictionary valueForKey:@"HighSchoolCity"];
                                             user.theHighSchool.stateCode = [userDictionary valueForKey:@"HighSchoolState"];
                                             user.theHighSchool.baseAverage = [NSNumber numberWithFloat:[[userDictionary valueForKey:@"BaseAverage"] floatValue]];
                                         }];
                               [context MR_saveOnlySelfAndWait];
                               if (successBlock)
                                   successBlock();
                           } operationFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                               if (failureBlock)
                                   failureBlock();
                           }];
}

#pragma mark - Conferences

+ (void)getAllConferencesOFullNameWithSuccessBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/GetConferences?$format=json", kSDBaseSigningDayURLString];
    [self startHTTPRequestOperationWithURLString:urlString
                           operationSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                               NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                               NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                                    options:kNilOptions
                                                                                      error:nil];
                               NSArray *resultsArray = [JSON valueForKey:@"d"];
                               for (NSDictionary *conferenceDictionaryWithNulls in resultsArray) {
                                   NSDictionary *conferenceDictionary = [conferenceDictionaryWithNulls dictionaryByReplacingNullsWithStrings];
                                   NSNumber *identifier = [NSNumber numberWithInt:[[conferenceDictionaryWithNulls valueForKey:@"ID"] intValue]];
                                   Conference *conference = [Conference MR_findFirstByAttribute:@"identifier"
                                                                                      withValue:identifier
                                                                                      inContext:context];
                                   if (!conference) {
                                       conference = [Conference MR_createInContext:context];
                                       conference.identifier = identifier;
                                   }
                                   conference.nameShort = [conferenceDictionary valueForKey:@"Name"];
                                   conference.nameFull = [conferenceDictionary valueForKey:@"FullName"];
                                   conference.logoUrl = [conferenceDictionary valueForKey:@"LogoURI"];
                                   conference.logoUrlBlack = [conferenceDictionary valueForKey:@"LogoURIBlack"];
                                   conference.isDivision1Conference = [NSNumber numberWithBool:[[conferenceDictionary valueForKey:@"IsDivision1Conference"] boolValue]];
                               }
                               [context MR_saveOnlySelfAndWait];
                               if (successBlock)
                                   successBlock();
                           } operationFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                               if (failureBlock)
                                   failureBlock();
                           }];
}

#pragma mark - States

+ (void)getAllStatesSuccessBlock:(void (^)(void))successBlock
                    failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/States?$format=json", kSDBaseSigningDayURLString];
    [self startHTTPRequestOperationWithURLString:urlString
                           operationSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                               NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                               NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                                    options:kNilOptions
                                                                                      error:nil];
                               NSArray *resultsArray = [JSON valueForKey:@"d"];
                               for (NSDictionary *stateDictionaryWithNulls in resultsArray) {
                                   NSDictionary *stateDictionary = [stateDictionaryWithNulls dictionaryByReplacingNullsWithStrings];
                                   NSString *code = [stateDictionary valueForKey:@"Code"];
                                   State *state = [State MR_findFirstByAttribute:@"code"
                                                                       withValue:code
                                                                       inContext:context];
                                   if (!state) {
                                       state = [State MR_createInContext:context];
                                       state.code = code;
                                   }
                                   state.name = [stateDictionary valueForKey:@"Name"];
                                   state.isInUS = [stateDictionary valueForKey:@"IsInUS"];
                               }
                               [context MR_saveOnlySelfAndWait];
                               if (successBlock)
                                   successBlock();
                           } operationFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                               if (failureBlock)
                                   failureBlock();
                           }];
}

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
                          withContext:(NSManagedObjectContext *)context
            withBlockForSpecificTypes:(void (^)(NSDictionary *userDictionary, NSManagedObjectContext *context, User *user))specificTypeOfUserCreationBlock
{
//    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                         options:kNilOptions
                                                           error:nil];
    NSArray *resultsArray = [JSON valueForKey:@"d"];
    for (NSDictionary *userDictionaryWithNulls in resultsArray) {
        NSDictionary *userDictionary = [userDictionaryWithNulls dictionaryByReplacingNullsWithStrings];
        User *user = [User getUserWithBasicUserInfoFromUserDictionary:userDictionary
                                                           andContext:context];
        if (specificTypeOfUserCreationBlock)
            specificTypeOfUserCreationBlock(userDictionary, context, user);
    }
//    [context MR_saveOnlySelfAndWait];
}

+ (NSString *)makeRequestsStringFromRequestsArray:(NSArray *)requestsArray
                     withUrlEntityNameToBeEqualTo:(NSString *)entityName
                       appendingWithLogicalString:(NSString *)logicalString
{
    NSString *requestsString = @"";
    for (int i = 0; i < [requestsArray count]; i++) {
        NSString *requestString = [requestsArray objectAtIndex:i];
        
        NSDecimal decimalValue;
        NSScanner *scanner = [NSScanner scannerWithString:requestString];
        [scanner scanDecimal:&decimalValue];
        BOOL isDecimal = [scanner isAtEnd];
        
        if (isDecimal)
            requestsString = [requestsString stringByAppendingFormat:@"%@ eq %@ ", entityName, requestString];
        else
            requestsString = [requestsString stringByAppendingFormat:@"%@ eq '%@' ", entityName, requestString];
        if (logicalString) {
            if (i != ([requestsArray count] - 1))
                requestsString = [requestsString stringByAppendingString:logicalString];
        }
    }
    return requestsString;
}

+ (NSString *)makeFilterStringFromRequestStringsArray:(NSArray *)requestStringsArray
{
    NSString *filterString = @"";
    for (int i = 0; i < [requestStringsArray count]; i++) {
        NSString *paramsString = [requestStringsArray objectAtIndex:i];
        filterString = [filterString stringByAppendingFormat:@"(%@) ", paramsString];
        if (i != ([requestStringsArray count] - 1))
            filterString = [filterString stringByAppendingFormat:@"and "];
    }
    return filterString;
}

@end
