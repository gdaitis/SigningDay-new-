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

@implementation SDLandingPagesService

#pragma mark - Players

+ (void)getPlayersOrderedByDescendingBaseScoreFrom:(NSInteger)pageBeginIndex
                                                to:(NSInteger)pageEndIndex
                                 completionHandler:(void (^)(void))completionBlock
                                      failureBlock:(void (^)(void))failureBlock
{
    if (pageBeginIndex > pageEndIndex) {
        NSLog(@"Cannot load players: end index is lower that begin index");
        return;
    }
    int top = pageEndIndex - pageBeginIndex;
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/PlayersDto?$orderby=BaseScore%%20desc&skip=%d&$top=%d&$format=json", kSDBaseSigningDayURLString, pageBeginIndex, top];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:kNilOptions
                                                                error:nil] dictionaryByReplacingNullsWithStrings];
        completionBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    [operation start];
}

#pragma mark - Teams

#pragma mark - HighSchools

@end
