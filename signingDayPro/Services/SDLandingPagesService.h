//
//  SDLandingPagesService.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

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
+ (void)getTeamsOrderedByDescendingTotalScoreFrom:(NSInteger)pageBeginIndex
                                               to:(NSInteger)pageEndIndex
                                     successBlock:(void (^)(void))successBlock
                                     failureBlock:(void (^)(void))failureBlock;

@end
