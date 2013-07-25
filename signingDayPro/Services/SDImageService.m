//
//  SDImageService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDImageService.h"
#import "SDAPIClient.h"
#import "ImageData.h"
#import "AFNetworking.h"

// set he update interval
#define kUpdateIntervalInHours 1

@interface SDImageService ()

- (void)downloadAndSaveImageWithUrlString:(NSString *)urlString
                                  success:(void (^)(UIImage *image))successBlock;
- (NSString *)documentsPathForFileName:(NSString *)name;

@end

@implementation SDImageService

+ (SDImageService *)sharedService
{
    static SDImageService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[SDImageService alloc] init];
    });
    
    return _sharedService;
}

- (void)getImageWithURLString:(NSString *)urlString
                      success:(void (^)(UIImage *image))successBlock
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    ImageData *imageData = imageData = [ImageData MR_findFirstByAttribute:@"urlString" withValue:urlString inContext:context];
    // Case 1:
    if (!imageData) {
        imageData = [ImageData MR_createInContext:context];
        imageData.updateDate = [NSDate date];
        imageData.urlString = urlString;
        [context MR_saveToPersistentStoreAndWait];
        [self downloadAndSaveImageWithUrlString:imageData.urlString
                                        success:successBlock];
        return;
    }
    // Case 2:
    NSTimeInterval timeInterval = [imageData.updateDate timeIntervalSinceNow];
    double secondsInOneHour = 3600;
    float timePassed = timeInterval / secondsInOneHour;
    if (timePassed > kUpdateIntervalInHours) {
        imageData.updateDate = [NSDate date];
        [context MR_saveToPersistentStoreAndWait];
        [self downloadAndSaveImageWithUrlString:imageData.urlString
                                        success:successBlock];
        return;
    }
    // Case 3:
    if (successBlock)
        successBlock(imageData.image);
}

- (void)downloadAndSaveImageWithUrlString:(NSString *)urlString
                                  success:(void (^)(UIImage *image))successBlock
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                                           success:^(UIImage *image) {
                                                                                               NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                                               ImageData *imageData = [ImageData MR_findFirstByAttribute:@"urlString"
                                                                                                                                               withValue:urlString inContext:context];
                                                                                               imageData.image = image;
                                                                                               [context MR_saveToPersistentStoreAndWait];
                                                                                               if (successBlock) {
                                                                                                   successBlock(image);
                                                                                               }
                                                                                               
                                                                                           }];
    [operation start];
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name]; 
}

@end
