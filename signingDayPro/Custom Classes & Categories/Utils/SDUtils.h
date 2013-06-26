//
//  SDUtils.h
//  SigningDay
//
//  Created by Lukas Kekys on 5/21/13.
//
//

#import <Foundation/Foundation.h>

@class ActivityStory;

@interface SDUtils : NSObject

+ (void)setupCoreDataStack;
- (int)heightForActivityStory:(ActivityStory *)activityStory;

@end
