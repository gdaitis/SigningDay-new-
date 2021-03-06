//
//  SDLandingPagesService.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDLandingPagesService : NSObject

/*
 BIG NOTE: do the list ordering in CoreData!
*/


// Players
+ (void)getPlayersOrderedByDescendingBaseScoreFrom:(NSInteger)pageBeginIndex
                                                to:(NSInteger)pageEndIndex
                                          forClass:(NSString *)classString
                                      successBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock;
+ (void)searchForPlayersWithNameString:(NSString *)searchString
                                  from:(NSInteger)pageBeginIndex
                                    to:(NSInteger)pageEndIndex
                 stateCodeStringsArray:(NSArray *)statesArray
                classYearsStringsArray:(NSArray *)classesArray
                  positionStringsArray:(NSArray *)positionsArray
                              sortedBy:(NSString *)sortOption
                          successBlock:(void (^)(void))successBlock
                          failureBlock:(void (^)(void))failureBlock;

+ (void)searchAllPlayersWithNameSubstring:(NSString *)nameSubstring
                             successBlock:(void (^)(void))successBlock
                             failureBlock:(void (^)(void))failureBlock;

// Teams
+ (void)getTeamsOrderedByDescendingTotalScoreWithPageNumber:(NSInteger)pageNumber
                                                   pageSize:(NSInteger)pageSize
                                                classString:(NSString *)classString
                                         conferenceIdString:(NSString *)conferenceIdString
                                               successBlock:(void (^)(void))successBlock
                                               failureBlock:(void (^)(void))failureBlock;

+ (void)searchForTeamsWithNameString:(NSString *)searchString
                  conferenceIDString:(NSString *)conferenceString
                         classString:(NSString *)classString
                        successBlock:(void (^)(void))successBlock
                        failureBlock:(void (^)(void))failureBlock;

+ (void)searchForTeamsWithNameString:(NSString *)searchString
                        successBlock:(void (^)(void))successBlock
                        failureBlock:(void (^)(void))failureBlock;
+ (void)getTeamsOrderedByDescendingTotalScoreWithPageNumber:(NSInteger)pageNumber
                                                   pageSize:(NSInteger)pageSize
                                               successBlock:(void (^)(void))successBlock
                                               failureBlock:(void (^)(void))failureBlock;
+ (void)getTeamsWithSearchString:(NSString *)searchString
                 completionBlock:(void (^)(void))completionBlock
                    failureBlock:(void (^)(void))failureBlock;

// High Schools
+ (void)getAllHighSchoolsForAllStatesForYearString:(NSString *)yearString
                                        pageNumber:(NSInteger)pageNumber
                                          pageSize:(NSInteger)pageSize
                                      successBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock;
+ (void)getAllHighSchoolsForState:(NSString *)stateCode
                    ForYearString:(NSString *)yearString
                       pageNumber:(NSInteger)pageNumber
                         pageSize:(NSInteger)pageSize
                     successBlock:(void (^)(void))successBlock
                     failureBlock:(void (^)(void))failureBlock;
+ (void)searchForHighSchoolsInAllStatesWithNameString:(NSString *)searchString
                                           yearString:(NSString *)yearString
                                         successBlock:(void (^)(void))successBlock
                                         failureBlock:(void (^)(void))failureBlock;
+ (void)searchForHighSchoolsWithNameString:(NSString *)searchString
                                yearString:(NSString *)yearString
                     stateCodeStringsArray:(NSArray *)statesArray
                              successBlock:(void (^)(void))successBlock
                              failureBlock:(void (^)(void))failureBlock;

+ (void)searchAllHighSchoolsWithNameSubstring:(NSString *)nameSubstring
                                 successBlock:(void (^)(void))successBlock
                                 failureBlock:(void (^)(void))failureBlock;


//Coaches
+ (void)searchAllCoachesWithNameSubstring:(NSString *)nameSubstring
                             successBlock:(void (^)(void))successBlock
                             failureBlock:(void (^)(void))failureBlock;


// Conferences
+ (void)getAllConferencesOFullNameWithSuccessBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock;
// States
+ (void)getAllStatesSuccessBlock:(void (^)(void))successBlock
                    failureBlock:(void (^)(void))failureBlock;

@end
