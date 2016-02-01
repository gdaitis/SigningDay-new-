//
//  SDSharingService.h
//  SigningDay
//
//  Created by lite on 17/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDSharingService : NSObject

+ (void)shareString:(NSString *)string
        forFacebook:(BOOL)facebookSharing
         andTwitter:(BOOL)twitterSharing;

@end
