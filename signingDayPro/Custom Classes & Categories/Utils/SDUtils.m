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
        NSLog(@"Database incompatible");
        [MagicalRecord setupAutoMigratingCoreDataStack];
    }
    else {
        
        NSLog(@"Database compatible");
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
                          constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)
                              lineBreakMode:UILineBreakModeWordWrap];
    
    //    if (!_activityStory.imagePath {
    if (true) {
        result = size.height + 10/*offset*/;
    }
    else {
        result = size.height + 10/*offset*/ + 150;/*imageView size*/
    }
    
    return result;
}



@end
