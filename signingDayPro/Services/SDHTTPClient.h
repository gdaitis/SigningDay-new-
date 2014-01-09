//
//  SDHTTPClient.h
//  SigningDay
//
//  Created by Lukas Kekys on 1/8/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPClient.h>

@interface SDHTTPClient : AFHTTPClient

+ (SDHTTPClient *)sharedClient;

@end
