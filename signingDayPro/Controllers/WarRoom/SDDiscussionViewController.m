//
//  SDDiscussionViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDDiscussionViewController.h"
#import "Thread.h"
#import "SDPostCell.h"
#import "UIView+NibLoading.h"

@implementation SDDiscussionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *postText = @"Aasdjfg kadshfgsherjgsdnfbvn ansdf asldfj a;lksdfl jvbn xcn va;lsdhtj sdfnv xclvjkbs;fjg sd;fn sdn fljalsdjf sdf";
    return [self getHeightForCellWithPostText:postText];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return /*[self.dataArray count]*/3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDPostCellID";
    SDPostCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDPostCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Configure the cell (give data nomnomnom)
    
    return cell;
}

//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];/
//}

#pragma mark - Private methods

- (CGFloat)getHeightForCellWithPostText:(NSString *)postText
{
    int cellHeight = 0;
    
    cellHeight += 31; // y position of post text view
    
    CGSize postTextSize = [postText sizeWithFont:[UIFont systemFontOfSize:kSDPostCellDefaultFontSize]
                               constrainedToSize:CGSizeMake(kSDPostCellMaxPostLabelWidth, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    
    cellHeight += postTextSize.height;
    cellHeight += kSDPostCellPostTextAndDateLabelGapHeight;
    cellHeight += 16; // height of date label
    cellHeight += kSDPostCellDateLabelAndBottomLineGapHeight;
    cellHeight += 1; // height of bottom line
    
    return cellHeight;
}

@end
