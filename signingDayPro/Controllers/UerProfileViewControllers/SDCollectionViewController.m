//
//  SDCollectionViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCollectionViewController.h"
#import "SDCollectionCell.h"
#include <stdlib.h>
#import "AFNetworking.h"
#import "SDImageEnlargementView.h"
#import "MediaGallery.h"
#import "MediaItem.h"
#import "MBProgressHUD.h"

@interface SDCollectionViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SDCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UINib *cellNib = [UINib nibWithNibName:@"SDCollectionCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"CollectionCellID"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self reload];
    [self checkServer];
}

- (void)checkServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.collectionView
                                              animated:YES];
    hud.labelText = @"Loading";
    
    void (^completionBlock)(void) = ^(void){
        [MBProgressHUD hideHUDForView:self.collectionView
                             animated:YES];
        [self reload];
    };
    void (^failureBlock)(void) = ^(void){
        [MBProgressHUD hideHUDForView:self.collectionView
                             animated:YES];
    };
    
    if (self.galleryType == SDGalleryTypePhotos)
        [SDProfileService getPhotosForUser:self.user
                           completionBlock:completionBlock
                              failureBlock:failureBlock];
    if (self.galleryType == SDGalleryTypeVideos)
        [SDProfileService getVideosForUser:self.user
                           completionBlock:completionBlock
                              failureBlock:failureBlock];
}

- (void)reload
{
    NSPredicate *mediaGalleryPredicate = [NSPredicate predicateWithFormat:@"user == %@ AND galleryType == %d", self.user, self.galleryType];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    MediaGallery *mediaGallery = [MediaGallery MR_findFirstWithPredicate:mediaGalleryPredicate
                                                               inContext:context];
    self.dataArray = [MediaItem MR_findAllSortedBy:@"createdDate"
                                         ascending:NO
                                     withPredicate:[NSPredicate predicateWithFormat:@"mediaGallery == %@", mediaGallery]
                                         inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [self.collectionView reloadData];
}

#pragma mark - UIColectionView datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SDCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CollectionCellID" forIndexPath:indexPath];
    
    [cell.imageView cancelImageRequestOperation];
    cell.backgroundColor = [UIColor clearColor];
    MediaItem *mediaItem = [self.dataArray objectAtIndex:indexPath.row];
    
    [cell.imageView cancelImageRequestOperation];
    cell.imageView.image = nil;
    [cell.imageView setImageWithURL:[NSURL URLWithString:mediaItem.thumbnailUrl] placeholderImage:nil];
    
    return cell;
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaItem *mediaItem = [self.dataArray objectAtIndex:indexPath.row];
    SDImageEnlargementView *imageEnlargemenetView = [[SDImageEnlargementView alloc] initWithFrame:self.view.frame
                                                                                         andImage:mediaItem.fileUrl];
    [imageEnlargemenetView presentImageViewInView:self.navigationController.view];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Item deselection
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize result = CGSizeMake(100, 100);
    return result;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
