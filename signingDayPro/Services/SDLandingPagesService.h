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
                                 completionHandler:(void (^)(void))completionBlock
                                      failureBlock:(void (^)(void))failureBlock;

@end
