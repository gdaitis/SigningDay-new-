//
//  SDUtils.h
//  SigningDay
//
//  Created by Lukas Kekys on 5/21/13.
//
//

#import <Foundation/Foundation.h>

#define kMaxNamesSymbolSize 38

@class ActivityStory,User;

@interface SDUtils : NSObject

+ (void)setupCoreDataStack;
+ (int)heightForActivityStory:(ActivityStory *)activityStory;
+ (int)heightForActivityStory:(ActivityStory *)activityStory forUITextView:(UITextView *)textView;

+ (NSString *)formatedTimeForDate:(NSDate *)date;
+ (NSString *)formatedDateStringFromDateToNow:(NSDate *)date;
+ (NSString *)formatedDateStringFromDate:(NSDate *)date;
+ (NSDate *)notLocalizedDateFromString:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSAttributedString *)attributedStringWithText:(NSString *)firstText firstColor:(UIColor *)firstColor andSecondText:(NSString *)secondText andSecondColor:(UIColor *)secondColor andFirstFont:(UIFont *)firstFont andSecondFont:(UIFont *)secondFont;
+ (NSAttributedString *)attributedStringWithText:(NSString *)text andColor:(UIColor *)color andFont:(UIFont *)font;
//+ (NSAttributedString *)attributedWallpostStringWithText:(NSString *)firstText firstColor:(UIColor *)firstColor andSecondText:(NSString *)secondText andSecondColor:(UIColor *)secondColor andFirstFont:(UIFont *)firstFont andSecondFont:(UIFont *)secondFont;

+ (NSString *)attributeStringForUser:(User *)user;

//E.g returns 5'6"
+ (NSString *)stringHeightFromInches:(int)inches;

+ (NSString *)formattedForrumReplyFromString:(NSString *)reply;
+ (NSAttributedString *)buildDTCoreTextStringForSigningdayWithHTMLText:(NSString *)htmlString;
+ (NSString *)currentYear;

@end
