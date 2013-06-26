//
//  SDActivityFeedViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 6/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SDActivityFeedCell.h"
#import "SDActivityFeedButtonView.h"
#import "ActivityStory.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "User.h"
#import "SDActivityFeedCellContentView.h"

#define kButtonImageViewTag 999
#define kButtonCommentLabelTag 998

@interface SDActivityFeedViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SDActivityFeedViewController

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
    
    self.tableView.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
        
//    UINib *rowCellNib = [UINib nibWithNibName:@"SDActivityFeedCell" bundle:[NSBundle mainBundle]];
//    [self.tableView registerNib:rowCellNib forCellReuseIdentifier:@"ActivityFeedCellId"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#warning TEST
    [self showProgressHudInView:self.view withText:@"Loading"];
    [SDActivityFeedService getActivityStoriesWithSuccessBlock:^{
        [self loadData];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView datasource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityStory *activityStory = [_dataArray objectAtIndex:indexPath.row];
    
    int contentHeight = [SDUtils heightForActivityStory:activityStory];
    int result = 130/*buttons images etc..*/ + contentHeight;

    return result;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDActivityFeedCell *cell = nil;
    NSString *cellIdentifier = @"ActivityFeedCellId";
    
    cell = (SDActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Load cell
        NSArray *topLevelObjects = nil;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDActivityFeedCell" owner:nil options:nil];
        // Grab cell reference which was set during nib load:
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDActivityFeedCell class]]) {
                cell = currentObject;
                break;
            }
        }
        [self setupCell:cell];
    }
    
    cell.likeButton.tag = indexPath.row;
    cell.commentButton.tag = indexPath.row;
    
    ActivityStory *activityStory = [_dataArray objectAtIndex:indexPath.row];
    
    cell.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likes count]];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.comments count]];
//    cell.nameLabel.text =activityStory.author.name;
    [cell.resizableActivityFeedView setActivityStory:activityStory];
    
    cell.nameLabel.text = @"Celes";
    cell.yearLabel.text = @"- DE, 2014";
    cell.postDateLabel.text = @"4 Minutes ago";
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - image positioning &cell setup

- (void)setupCell:(SDActivityFeedCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.thumbnailImageView.backgroundColor = [UIColor greenColor];
    
    cell.containerView.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f] CGColor];
    cell.containerView.layer.borderWidth = 1.0f;
    cell.containerView.layer.cornerRadius = 4.0f;
    
    cell.likeButtonView.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f] CGColor];
    cell.likeButtonView.layer.borderWidth = 1.0f;
    cell.likeButtonView.layer.cornerRadius = 4.0f;
    cell.likeButtonView.clipsToBounds = YES;
    [cell.likeButtonView.layer setMasksToBounds:YES];
    
    cell.commentButtonView.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f] CGColor];
    cell.commentButtonView.layer.borderWidth = 1.0f;
    cell.commentButtonView.layer.cornerRadius = 4.0f;
    cell.commentButtonView.clipsToBounds = YES;
    
    cell.buttonsBackgroundView.layer.borderColor = [[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f] CGColor];
    cell.buttonsBackgroundView.layer.borderWidth = 1.0f;
    
    cell.thumbnailImageView.layer.cornerRadius = 4.0f;
}

//- (void)calculateImageAndLabelPositionForButton:(UIButton *)button
//{
//    CGSize size = [button.titleLabel.text sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, button.titleLabel.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
//    
//    UIImageView *imageView = (UIImageView *)[button viewWithTag:kButtonImageViewTag];
//    UILabel *countLabel = (UILabel *)[button viewWithTag:kButtonCommentLabelTag];
//    
//    CGRect frame = imageView.frame;
//    frame.origin.x = button.center.x - size.width/2 - imageView.frame.size.width/2 -5;
//    imageView.frame = frame;
//    
//    frame = countLabel.frame;
//    frame.origin.x = button.center.x + size.width/2 + 5;
//    imageView.frame = frame;
//}

- (void)loadData
{
    self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO];
    [self.tableView reloadData];
}


@end
