//
//  SDUtils.h
//  SigningDay
//
//  Created by Lukas Kekys on 5/21/13.
//
//

#import <Foundation/Foundation.h>

@class ActivityStory,User;

@interface SDUtils : NSObject

+ (void)setupCoreDataStack;
+ (int)heightForActivityStory:(ActivityStory *)activityStory;
+ (NSString *)formatedTimeForDate:(NSDate *)date;
+ (NSString *)formatedDateStringFromDateToNow:(NSDate *)date;
+ (NSString *)formatedDateStringFromDate:(NSDate *)date;
+ (NSDate *)notLocalizedDateFromString:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSAttributedString *)attributedStringWithText:(NSString *)firstText firstColor:(UIColor *)firstColor andSecondText:(NSString *)secondText andSecondColor:(UIColor *)secondColor andFirstFont:(UIFont *)firstFont andSecondFont:(UIFont *)secondFont;
+ (NSAttributedString *)attributedStringWithText:(NSString *)text andColor:(UIColor *)color andFont:(UIFont *)font;
//+ (NSAttributedString *)attributedWallpostStringWithText:(NSString *)firstText firstColor:(UIColor *)firstColor andSecondText:(NSString *)secondText andSecondColor:(UIColor *)secondColor andFirstFont:(UIFont *)firstFont andSecondFont:(UIFont *)secondFont;

+ (NSString *)attributeStringForUser:(User *)user;

@end
