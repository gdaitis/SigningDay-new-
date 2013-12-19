//
//  SDUtils.m
//  SigningDay
//
//  Created by Lukas Kekys on 5/21/13.
//
//

#import "SDUtils.h"
#import "ActivityStory.h"
#import "User.h"
#import "WebPreview.h"
#import "SDProfileService.h"
#import "Player.h"
#import "Team.h"
#import "Coach.h"
#import "HighSchool.h"
#import "Member.h"
#import "SDLoginService.h"
#import <CoreText/CoreText.h>
#import <DTCSSStylesheet.h>
#import <DTHTMLAttributedStringBuilder.h>
#import <DTCoreTextConstants.h>

@interface SDUtils()

+ (BOOL)databaseCompatible;

@end

@implementation SDUtils

//+ (void)setupCoreDataStack
//{
//    BOOL needsLogout = NO;
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"buildVersion"] intValue] < [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue]) {
//        NSError *error;
//        [[NSFileManager defaultManager] removeItemAtPath:[NSPersistentStore MR_urlForStoreName:@"SigningDay.sqlite"].path
//                                                   error:&error];
//        [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"buildVersion"];
//        needsLogout = YES;
//    }
//    [MagicalRecord setupCoreDataStackWithStoreNamed:@"SigningDay.sqlite"];
//    
//    if (needsLogout) {
//        [SDLoginService logout];
//    }
//}

+ (void)setupCoreDataStack
{
    BOOL needsLogout = NO;
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"buildVersion"] isEqualToString: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]) {
        NSError *error;
        
        NSLog(@"Old database will be deleted");
        NSString *path = [NSPersistentStore MR_urlForStoreName:@"SigningDay.sqlite"].path;
        NSString *previousVersionPath = [NSPersistentStore MR_urlForStoreName:@"CoreDataStore.sqlite"].path;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            [[NSFileManager defaultManager] removeItemAtPath:path
                                                       error:&error];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:previousVersionPath])
            [[NSFileManager defaultManager] removeItemAtPath:previousVersionPath
                                                       error:&error];
        
        [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"buildVersion"];
        needsLogout = YES;
    }
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"SigningDay.sqlite"];
    
    if (needsLogout) {
        [SDLoginService cleanUpUserSession];
    }
}


#pragma mark - Compatibility checking

+ (BOOL)databaseCompatible
{
    //check if migration is needed
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [NSPersistentStoreCoordinator MR_defaultStoreCoordinator];
    NSURL *storeUrl = [NSPersistentStore MR_defaultLocalStoreUrl];
    
    // Determine if a migration is needed
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeUrl
                                                                                            error:&error];
    NSManagedObjectModel *destinationModel = [persistentStoreCoordinator managedObjectModel];
    BOOL result = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    
    return result;
}

+ (int)heightForActivityStory:(ActivityStory *)activityStory
{
    int result = 0;

    NSMutableString *contentText = [[NSMutableString alloc] init];
    if (activityStory.webPreview) {
        
        if ([activityStory.webPreview.link length] > 0) {
            [contentText appendFormat:@"%@\n\n",activityStory.webPreview.link];
        }
        if ([activityStory.webPreview.siteName length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.webPreview.siteName];
        }
        if ([activityStory.webPreview.webPreviewTitle length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.webPreview.webPreviewTitle];
        }
    }
    else {
        if ([activityStory.activityTitle length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.activityTitle];
        }
        if ([activityStory.activityDescription length] > 0) {
            [contentText appendString:activityStory.activityDescription];
        }
    }
    
    CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:15.0f]
                          constrainedToSize:CGSizeMake(288, CGFLOAT_MAX)];
    
    if ([activityStory.mediaType length] > 0) {
        result = size.height + 10/*offset*/ + 150;/*imageView size*/
    }
    else {
        result = size.height + 10/*offset*/;
    }

    return result;
}

+ (int)heightForActivityStory:(ActivityStory *)activityStory forUITextView:(UITextView *)textView
{
    int result = 0;
    
    
    NSMutableString *contentText = [[NSMutableString alloc] init];
    if (activityStory.webPreview) {
        
        if ([activityStory.webPreview.link length] > 0) {
            [contentText appendFormat:@"%@\n\n",activityStory.webPreview.link];
        }
        if ([activityStory.webPreview.siteName length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.webPreview.siteName];
        }
        if ([activityStory.webPreview.webPreviewTitle length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.webPreview.webPreviewTitle];
        }
        if ([activityStory.webPreview.excerpt length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.webPreview.excerpt];
        }
    }
    else {
        if ([activityStory.activityTitle length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.activityTitle];
        }
        if ([activityStory.activityDescription length] > 0) {
            [contentText appendString:activityStory.activityDescription];
        }
    }
    
    
    CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:15.0f]
                          constrainedToSize:CGSizeMake(textView.bounds.size.width-10, CGFLOAT_MAX)];
    
    if (activityStory.mediaType) {
        result = size.height + 10/*offset*/ + 150;/*imageView size*/
    }
    else {
        result = size.height + 10/*offset*/;
    }
    
    return result;
}

+ (NSString *)formatedTimeForDate:(NSDate *)date
{
    NSString *result = nil;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date toDate:[NSDate date] options:nil];
    
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    if (year > 0) {
        if (year == 1) {
            result = [NSString stringWithFormat:@"%d year ago",year];
        }
        else {
            result = [NSString stringWithFormat:@"%d years ago",year];
        }
    }
    else {
        if (month > 0) {
            if (month == 1) {
                result = [NSString stringWithFormat:@"%d month ago",month];
            }
            else {
                result = [NSString stringWithFormat:@"%d months ago",month];
            }
        }
        else {
            if (day > 0) {
                if (day == 1) {
                    result = [NSString stringWithFormat:@"%d day ago",day];
                }
                else {
                    result = [NSString stringWithFormat:@"%d days ago",day];
                }
            }
            else {
                if (hour > 0) {
                    if (hour == 1) {
                        result = [NSString stringWithFormat:@"%d hour ago",hour];
                    }
                    else {
                        result = [NSString stringWithFormat:@"%d hours ago",hour];
                    }
                }
                else {
                    if (minute > 0) {
                        if (minute == 1) {
                            result = [NSString stringWithFormat:@"%d minute ago",minute];
                        }
                        else {
                            result = [NSString stringWithFormat:@"%d minutes ago",minute];
                        }
                    }
                    else {
                        result = [NSString stringWithFormat:@"few seconds ago"];
                    }
                }
            }
        }
    }
    return result;
}

+ (NSDate *)dateFromString:(NSString *)dateString
{
    if (!dateString || [dateString isEqual:[NSNull null]] || [dateString isEqual:@""]) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    if (!date) {
        
        NSString *formatedDateString = [dateString stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange([dateString length]-4, 3)];
        NSArray *dateFormatterList = [NSArray arrayWithObjects:@"yyyy-MM-dd'T'HH:mm:ss.SSS",
                                      @"yyyy-MM-dd'T'HH:mm:ss", @"yyyy-MM-dd'T'HH:mm:ss.SS", @"yyyy-MM-dd'T'HH:mm:ss.S", @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ", @"yyyy-MM-dd'T'HH:mm:ssZZZ", nil];//include all possible dateformats here
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        for (NSString *dateFormatterString in dateFormatterList) {
            
            [dateFormatter setDateFormat:dateFormatterString];
            NSDate *originalDate = [dateFormatter dateFromString:formatedDateString];
            
            if (originalDate) {
                date = originalDate;
                break;
            }
        }
    }
    
    return date;
}

+ (NSDate *)notLocalizedDateFromString:(NSString *)dateString
{
    //ignores timezone
    NSString *clippedDate = [dateString substringToIndex:[dateString length]-6];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
    
    NSDate *date = [dateFormatter dateFromString:clippedDate];
    
    if (!date) {
        
        NSArray *dateFormatterList = [NSArray arrayWithObjects:@"yyyy-MM-dd'T'HH:mm:ss.SSS",
                                      @"yyyy-MM-dd'T'HH:mm:ss", @"yyyy-MM-dd'T'HH:mm:ss.SS", @"yyyy-MM-dd'T'HH:mm:ss.S", @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ", @"yyyy-MM-dd'T'HH:mm:ssZZZ", nil];//include all possible dateformats here
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        for (NSString *dateFormatterString in dateFormatterList) {
            [dateFormatter setDateFormat:dateFormatterString];
            NSDate *originalDate = [dateFormatter dateFromString:clippedDate];
            
            if (originalDate) {
                date = originalDate;
                break;
            }
        }
    }
    
    return date;
}

+ (NSString *)formatedDateStringFromDateToNow:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit |NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date toDate:[NSDate date] options:nil];
    
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
    NSString *result = [NSString stringWithFormat:@"%d/%d/%d %d:%d:%d",month,day,year,hour,minute,second];
    
    return result;
}

+ (NSString *)formatedDateStringFromDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit |NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
    NSString *result = [NSString stringWithFormat:@"%d/%d/%d %02d:%02d:%02d",month,day,year,hour,minute,second];
    
    return result;
}

+ (NSString *)formatedLocalizedDateStringFromDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSString * dateString = [NSString stringWithFormat: @"%d", month];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate* myDate = [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    NSString *stringFromDate = [formatter stringFromDate:myDate];
    
    
    NSString *result = [NSString stringWithFormat:@"%02d:%02d, %@ %d %d",hour,minute,stringFromDate,day,year];
    
    return result;
}

+ (NSAttributedString *)attributedStringWithText:(NSString *)firstText firstColor:(UIColor *)firstColor andSecondText:(NSString *)secondText andSecondColor:(UIColor *)secondColor andFirstFont:(UIFont *)firstFont andSecondFont:(UIFont *)secondFont
{
    NSString *str = [NSString stringWithFormat:@"%@ %@",firstText,secondText];
    
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:str];
    NSInteger firstLength = [firstText length];
    NSInteger secondLength = [secondText length];
    
    [attString addAttribute:NSFontAttributeName value:firstFont range:NSMakeRange(0, firstLength+1)];
    [attString addAttribute:NSFontAttributeName value:secondFont range:NSMakeRange(firstLength+1, secondLength)];
    [attString addAttribute:NSForegroundColorAttributeName value:firstColor range:NSMakeRange(0, firstLength+1 )];
    [attString addAttribute:NSForegroundColorAttributeName value:secondColor range:NSMakeRange(firstLength+1, secondLength)];
    
    return (NSAttributedString *)attString;
}

+ (NSAttributedString *)attributedStringWithText:(NSString *)text andColor:(UIColor *)color andFont:(UIFont *)font
{
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:text];
    NSInteger length = [text length];
    
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, length)];
    [attString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, length)];
    
    return (NSAttributedString *)attString;
}

+ (NSString *)attributeStringForUser:(User *)user
{
    int userTypeId = [user.userTypeId intValue];
    if (userTypeId > 0) {
        
        NSMutableString *result = [[NSMutableString alloc] initWithString:@"-"];
        if (userTypeId == SDUserTypePlayer) {
            if (user.thePlayer.position.length > 0) {
                [result appendFormat:@" %@", user.thePlayer.position];
            }
            if (user.thePlayer.userClass.length > 0) {
                if (![result isEqualToString:@"-"]) {
                    [result appendFormat:@","];
                }
                [result appendFormat:@" %@", user.thePlayer.userClass];
            }
        }
        else if (userTypeId == SDUserTypeTeam) {
            if (user.theTeam.location.length > 0) {
                [result appendFormat:@" %@", user.theTeam.location];
            }
            if (user.theTeam.stateCode.length > 0) {
                if (![result isEqualToString:@"-"]) {
                    [result appendFormat:@","];
                }
                [result appendFormat:@" %@", user.theTeam.stateCode];
            }
        }
        else if (userTypeId == SDUserTypeCoach) {
            if (user.theCoach.institution.length > 0) {
                [result appendFormat:@" %@", user.theCoach.institution];
            }
        }
        else if (userTypeId == SDUserTypeMember) {
            
        }
        else  if (userTypeId == SDUserTypeHighSchool) {
            if (user.theHighSchool.address.length > 0) {
                [result appendFormat:@" %@", user.theHighSchool.address];
            }
            if (user.theHighSchool.stateCode.length > 0) {
                if (![result isEqualToString:@"-"]) {
                    [result appendFormat:@","];
                }
                [result appendFormat:@" %@", user.theHighSchool.stateCode];
            }
        }
        if ([result isEqualToString:@"-"]) {
            return nil;
        }
        else {
            return result;
        }
    }
    else {
        return nil;
    }
}

+ (NSString *)stringHeightFromInches:(int)inches
{
    int feet = floor(inches/12);
    int inch = inches - feet*12;
    
    NSString *result = [NSString stringWithFormat:@"%d'%d\"",feet,inch];
    return result;
}

#pragma mark - forum reply formatter

+ (NSString *)formattedColoredForrumReplyFromString:(NSString *)reply
{
    NSString *htmlString = [reply stringByReplacingOccurrencesOfString:@"\\n" withString:@"<br>"];
    NSString *string = [htmlString stringByReplacingOccurrencesOfString:@"<blockquote class=\"quote\">" withString:@"<blockquote class=\"quote\" style=\"background-color:#f0f0f0\"><div style=\"padding:5px 10px 5px 10px;\">"];
    
    NSString *original = @"#f0f0f0";
    NSString *replacementGray = @"#E6E6E6";
    NSString *replacementDarkGray = @"#F2F2F2";
    NSRange r;
    int counter = 0;
    
    while ((r = [string rangeOfString:original options:NSRegularExpressionSearch]).location != NSNotFound) {
        if (counter % 2 == 0)
            string = [string stringByReplacingCharactersInRange:r withString:replacementGray];
        else
            string = [string stringByReplacingCharactersInRange:r withString:replacementDarkGray];
        counter++;
    }
    
    NSString *result = [string stringByReplacingOccurrencesOfString:@"</blockquote>" withString:@"</div></blockquote>"];
    
    return result;
}

+ (NSString *)formattedForrumReplyFromString:(NSString *)reply
{
    if (!reply) {
        return @"";
    }
    NSString *result = reply;
    
    NSRange range = [reply rangeOfString:@"<blockquote class=\"quote\">"
                                               options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        
        NSString *text = [reply stringByReplacingOccurrencesOfString:@"<blockquote class=\"quote\">"
                                                                        withString:@"<div class=\"quote-mycustom\"><blockquote class=\"quote\">"
                                                                           options:NSCaseInsensitiveSearch range:range];
        
        NSRange backwardRange = [text rangeOfString:@"</blockquote>" options:NSBackwardsSearch];
        if (backwardRange.location != NSNotFound) {
            NSString *formedtext = [text stringByReplacingOccurrencesOfString:@"</blockquote>"
                                                                 withString:@"</blockquote></div>"
                                                                    options:NSBackwardsSearch range:backwardRange];
            result = formedtext;
        }
    }
    
    result = [result stringByReplacingOccurrencesOfString:@"<div style=\"clear:both;\"></div>" withString:@""];

    return result;
}

+ (NSAttributedString *)buildDTCoreTextStringForSigningdayWithHTMLText:(NSString *)htmlString
{
    DTCSSStylesheet *customStyleSheet = [[DTCSSStylesheet alloc]
                                         initWithStyleBlock:@".quote {margin: 0;margin-bottom: 0px;color: #555555;font-size: 13px;} "
                                         ".quote-mycustom {padding:1px 1px 1px 1px;background-color: #f0f0f0;} "
                                         ".quote-user {color: black;font-size: 13px;} "
                                         ".quote-content {font-style: italic;color: #555555;font-size: 13px;}"];
    
    NSDictionary *builderOptions = @{DTDefaultFontFamily: @"Helvetica",
                                     DTDefaultLineHeightMultiplier: @"1.2",
                                     DTDefaultStyleSheet: customStyleSheet};
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:htmlData
                                                                                               options:builderOptions
                                                                                    documentAttributes:nil];
    NSAttributedString *result = [stringBuilder generatedAttributedString];
    
    return result;
}

+ (NSString *)currentYear
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger year = [components year];
    NSString *result = [NSString stringWithFormat:@"%d",year];
    
    return result;
}

@end
