//
//  SDUtils.m
//  SigningDay
//
//  Created by Lukas Kekys on 5/21/13.
//
//

#import "SDUtils.h"
#import "ActivityStory.h"

@interface SDUtils()

+ (BOOL)databaseCompatible;

@end

@implementation SDUtils

+ (void)setupCoreDataStack
{
    if (![self databaseCompatible]) {
        [MagicalRecord setupAutoMigratingCoreDataStack];
    }
    else {
        [MagicalRecord setupCoreDataStack];
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
    if ([activityStory.activityTitle length] > 0) {
        [contentText appendFormat:@"%@\n",activityStory.activityTitle];
    }
    if ([activityStory.activityDescription length] > 0) {
        [contentText appendString:activityStory.activityDescription];
    }
    CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:15.0f]
                          constrainedToSize:CGSizeMake(278, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    
    if ([activityStory.imagePath length] > 0) {
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
    

@end
