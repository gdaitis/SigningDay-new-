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
#import "UIImageView+Crop.h"

@interface SDCollectionViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UILabel *noItemsLabel;

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
    
    NSString *noMediaText;
    if (self.galleryType == SDGalleryTypePhotos)
        noMediaText = @"No photos";
    else
        noMediaText = @"no videos";
    UIFont *font = [UIFont fontWithName:@"BebasNeue" size:60.0];
    NSInteger width = 150;
    CGSize size = [noMediaText sizeWithFont:font
                          constrainedToSize:CGSizeMake(width, MAXFLOAT)
                              lineBreakMode:NSLineBreakByWordWrapping];
    self.noItemsLabel = [[UILabel alloc] init];
    self.noItemsLabel.text = noMediaText;
    self.noItemsLabel.font = font;
    self.noItemsLabel.textAlignment = NSTextAlignmentCenter;
    self.noItemsLabel.numberOfLines = 0;
    self.noItemsLabel.backgroundColor = [UIColor clearColor];
    self.noItemsLabel.textColor = [UIColor blackColor];
    CGRect frame = self.noItemsLabel.frame;
    frame.size = size;
    self.noItemsLabel.frame = frame;
    self.noItemsLabel.center = self.collectionView.center;
    [self.view addSubview:self.noItemsLabel];
    self.noItemsLabel.hidden = YES;
    
    [self reload];
    [self checkServer];
}

- (void)checkServer
{
    self.noItemsLabel.hidden = YES;
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
    if (self.dataArray.count == 0)
        self.noItemsLabel.hidden = NO;
    else
        self.noItemsLabel.hidden = YES;
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
    
    NSLog(@"media thumbnail url = %@",mediaItem.thumbnailUrl);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:mediaItem.thumbnailUrl]];
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                             cropedForSize:CGSizeMake(106, 106)
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       SDCollectionCell *aCell = (SDCollectionCell *)[cv cellForItemAtIndexPath:indexPath];
                                       if (image)
                                           aCell.imageView.image = image;
                                       else
                                            aCell.imageView.image = (self.galleryType == SDGalleryTypePhotos) ? nil : [UIImage imageNamed:@"Playbg.png"];
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       SDCollectionCell *aCell = (SDCollectionCell *)[cv cellForItemAtIndexPath:indexPath];
                                       aCell.imageView.image = (self.galleryType == SDGalleryTypePhotos) ? nil : [UIImage imageNamed:@"Playbg.png"];
                                   }];
    
    return cell;
}

#pragma mark - UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaItem *mediaItem = [self.dataArray objectAtIndex:indexPath.row];
    if (self.galleryType == SDGalleryTypePhotos) {
        SDImageEnlargementView *imageEnlargemenetView = [[SDImageEnlargementView alloc] initWithFrame:self.view.frame
                                                                                             andImage:mediaItem.fileUrl];
        [imageEnlargemenetView presentImageViewInView:self.navigationController.view];
    }
    if (self.galleryType == SDGalleryTypeVideos) {
        [self playVideoWithMediaFileUrlString:mediaItem.fileUrl];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Item deselection
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize result = CGSizeMake(106, 106);
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
