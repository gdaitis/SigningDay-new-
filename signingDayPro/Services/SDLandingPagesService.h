//
//  SDLandingPagesService.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

int const kSDLandingPagesServiceDefaultClass = 2014;

@interface SDLandingPagesService : NSObject

+ (void)getPlayersOrderedByDescendingBaseScoreFrom:(NSInteger)pageBeginIndex
                                                to:(NSInteger)pageEndIndex
                                      successBlock:(void (^)(void))successBlock
                                      failureBlock:(void (^)(void))failureBlock;
+ (void)searchForPlayersWithString:(NSString *)searchString
                      successBlock:(void (^)(void))successBlock
                      failureBlock:(void (^)(void))failureBlock;
+ (void)searchForPlayersWithNameString:(NSString *)searchString
                 stateCodeStringsArray:(NSArray *)statesArray
                classYearsStringsArray:(NSArray *)classesArray
                  positionStringsArray:(NSArray *)positionsArray
                          successBlock:(void (^)(void))successBlock
                          failureBlock:(void (^)(void))failureBlock;
+ (void)getTeamsOrderedByDescendingTotalScoreWithPageNumber:(NSInteger)pageNumber
                                                   pageSize:(NSInteger)pageSize
                                               successBlock:(void (^)(void))successBlock
                                               failureBlock:(void (^)(void))failureBlock;
+ (void)searchForTeamsWithNameString:(NSString *)searchString
                  conferenceIDString:(NSString *)conferenceString
                         classString:(NSString *)classString
                        successBlock:(void (^)(void))successBlock
                        failureBlock:(void (^)(void))failureBlock;
+ (void)getAllConferencesOrderedByFullNameWithSuccessBlock:(void (^)(void))successBlock
                                              failureBlock:(void (^)(void))failureBlock;

@end
