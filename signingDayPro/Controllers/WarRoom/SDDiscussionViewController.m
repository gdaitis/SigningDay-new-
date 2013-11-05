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
#import "SDWarRoomService.h"
#import "ForumReply.h"
#import "NSString+Additions.h"

@implementation SDDiscussionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl removeFromSuperview];
    
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkServer];
}

- (int)yCoordinateOfTableView
{
    return 42;
}

- (void)checkServer
{
    [self checkServerWithScrollingToBottom:NO];
}

- (void)checkServerWithScrollingToBottom:(BOOL)scrollToBottom
{
    [self showProgressHudInView:self.tableView
                       withText:@"Loding"];
    [SDWarRoomService getForumRepliesWithThreadId:self.currentThread.identifier
                                  completionBlock:^{
                                      [self reload];
                                      [self hideProgressHudInView:self.tableView];
                                      if (scrollToBottom)
                                          [self scrollToBottomAnimated:YES];
                                  } failureBlock:^{
                                      [self hideProgressHudInView:self.tableView];
                                  }];
}

- (void)reload
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [dataArray addObject:self.currentThread];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *repliesArray = [ForumReply MR_findByAttribute:@"thread.identifier"
                                                 withValue:self.currentThread.identifier
                                                andOrderBy:@"date"
                                                 ascending:YES
                                                 inContext:context];
    [dataArray addObjectsFromArray:repliesArray];
    self.dataArray = dataArray;
    
    [self.tableView reloadData];
}

- (void)send
{
    NSString *rightTrimmedMessage = [self.enterMessageTextView.text stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
    
    if (rightTrimmedMessage.length == 0) {
        [self clearChatInput];
        return;
    }
    
    [self clearChatInput];
    
    [SDWarRoomService postForumReplyForThreadId:self.currentThread.identifier
                                           text:rightTrimmedMessage
                                completionBlock:^{
                                    [self checkServerWithScrollingToBottom:YES];
                                } failureBlock:nil];
    
    [self scrollToBottomAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *postText;
    id dataObject = [self.dataArray objectAtIndex:[indexPath row]];
    if ([dataObject isKindOfClass:[Thread class]]) {
        Thread *thread = (Thread *)dataObject;
        postText = thread.bodyText;
    } else if ([dataObject isKindOfClass:[ForumReply class]]) {
        ForumReply *forumReply = (ForumReply *)dataObject;
        postText = forumReply.bodyText;
    } else {
        postText = @"";
    }
    
    return [self getHeightForCellWithPostText:postText];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
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
    id dataObject = [self.dataArray objectAtIndex:[indexPath row]];
    [cell setupWithDataObject:dataObject];
    
    return cell;
}

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
    cellHeight += 2; // height of bottom line
    
    return cellHeight;
}

@end
