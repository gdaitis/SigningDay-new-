//
//  SDCommentsViewController.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/29/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCommentsViewController.h"
#import "SDCommentCell.h"
#import "NSString+Additions.h"
#import "AFNetworking.h"
#import "Comment.h"
#import "User.h"
#import "ActivityStory.h"
#import "SDActivityFeedService.h"
#import "SDCommentsHeaderView.h"
#import "SDLikesViewController.h"

@interface SDCommentsViewController ()

@property (nonatomic, strong) SDCommentsHeaderView *contentHeaderView;

@end

@implementation SDCommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.contentHeaderView = [[SDCommentsHeaderView alloc] initWithFrame:CGRectMake(0, 44, 320, 40)];
    UIGestureRecognizer *gestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerClicked)];
    [self.contentHeaderView addGestureRecognizer:gestureRecogniser];
    self.contentHeaderView.likesCount = 45;
    [self.view addSubview:self.contentHeaderView];
    
    [self reload];
}

- (void)reload
{
    NSArray *unsortedComments = [self.activityStory.comments allObjects];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdDate"
                                                                     ascending:YES];
    self.dataArray = [unsortedComments sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSLog(@"Comments array is reloading");
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    // no [super viewWillAppear:animated] since it would scroll the view down - we don't need that
    
    [self checkServer];
}

- (void)checkServer
{
    [self showProgressHudInView:self.tableView
                       withText:@"Loading Comments"];
    [SDActivityFeedService getCommentsForActivityStory:self.activityStory
                                      withSuccessBlock:^{
                                          [self reload];
                                          [self hideProgressHudInView:self.tableView];
                                      } failureBlock:^{
                                          [self hideProgressHudInView:self.tableView];
                                          NSLog(@"Error loading comments");
                                      }];
}

- (void)headerClicked
{
    UIStoryboard *commentsStoryboard = [UIStoryboard storyboardWithName:@"CommentsViewStoryboard"
                                                                 bundle:nil];
    SDLikesViewController *likesViewController = [commentsStoryboard instantiateViewControllerWithIdentifier:@"LikesViewController"];
    likesViewController.activityStory = self.activityStory;
    [self.navigationController pushViewController:likesViewController
                                         animated:YES];
}

#pragma mark - UITableView data source and delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentCell";
    
    SDCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SDCommentCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    } else {
        [cell.userImageView cancelImageRequestOperation];
    }
    
    Comment *comment = [self.dataArray objectAtIndex:indexPath.row];
    cell.usernameLabel.text = comment.user.username;
    cell.messageTextLabel.text = comment.body;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:comment.updatedDate];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if ([today day] == [otherDay day] &&
        [today month] == [otherDay month] &&
        [today year] == [otherDay year] &&
        [today era] == [otherDay era]) {
        dateFormatter.dateFormat = @"hh:mm a";
    } else {
        dateFormatter.dateFormat = @"MMM dd";
    }
    
    cell.dateLabel.text = [dateFormatter stringFromDate:comment.updatedDate];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:comment.user.avatarUrl]];
    [cell.userImageView setImageWithURLRequest:request
                              placeholderImage:nil
                                 cropedForSize:CGSizeMake(26, 26)
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           SDCommentCell *myCell = (SDCommentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                           myCell.userImageView.image = image;
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           //
                                       }];
    
    [cell setNeedsLayout];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [self.dataArray objectAtIndex:indexPath.row];
    
    CGSize commentLabelSize = [comment.body sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14]
                           constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = 25 + commentLabelSize.height + 3 + 18 + 6;
    if (height < 68) {
        height = 68;
    }
    
    return height;
}

@end
