//
//  SDHTTPClient.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/8/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDHTTPClient.h"
#import "SDAPIClient.h"
#import <AFJSONRequestOperation.h>

@implementation SDHTTPClient

+ (SDHTTPClient *)sharedClient
{
    static SDHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SDHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kSDBaseSigningDayURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
