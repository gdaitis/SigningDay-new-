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
}

#pragma mark - UIColectionView datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
//    return [_dataArray count];
    int result = arc4random() % 9;
    NSLog(@"cell count = %d",result);
    return result;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SDCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CollectionCellID" forIndexPath:indexPath];
    
    [cell.imageView cancelImageRequestOperation];
    cell.backgroundColor = [UIColor clearColor];
    [cell.imageView setImageWithURL:[NSURL URLWithString:@"http://www.daltonstate.edu/testing-center/images/testing-center-index.jpg"] placeholderImage:nil];
    
    return cell;
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SDImageEnlargementView *imageEnlargemenetView = [[SDImageEnlargementView alloc] initWithFrame:self.view.frame andImage:@"http://www.daltonstate.edu/testing-center/images/testing-center-index.jpg"];
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