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

@interface SDActivityFeedViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;

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
    
//    UINib *rowCellNib = [UINib nibWithNibName:@"SDActivityFeedCell" bundle:[NSBundle mainBundle]];
//    [self.tableView registerNib:rowCellNib forCellReuseIdentifier:@"ActivityFeedCellId"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView datasource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int result = 200;
    
    if (indexPath.row == 1) {
        result = 300;
    }
    else if (indexPath.row == 2) {
        result = 150;
    }
    else if (indexPath.row == 3) {
        result = 250;
    }

    return result;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 24;
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
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.thumbnailImageView.backgroundColor = [UIColor greenColor];
        
        cell.containerView.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f] CGColor];
        cell.containerView.layer.borderWidth = 1.0f;
        cell.containerView.layer.cornerRadius = 2.0f;
        
        cell.thumbnailImageView.layer.cornerRadius = 4.0f;
    }
    
    [cell.likeButton setTitle:@"Like" forState:UIControlStateNormal];
    [cell.commentButton setTitle:@"Comment" forState:UIControlStateNormal];
    
    cell.likeButton.tag = indexPath.row;
    cell.commentButton.tag = indexPath.row;
    
    
    
    //=================== TESTING ==================================
    if (indexPath.row == 0) {
        cell.nameLabel.text = @"Celes";
    }
    else if (indexPath.row == 1) {
        cell.nameLabel.text = @"Celes vardo";
    }
    else if (indexPath.row == 2) {
        cell.nameLabel.text = @"Celes vardo label";
    }
    else if (indexPath.row == 3) {
        cell.nameLabel.text = @"Celes vardo label ilgio";
    }
    else {
        cell.nameLabel.text = @"Celes vardo label ilgio testavimas";
    }
    
    cell.yearLabel.text = @"- DE, 2014";
    cell.postDateLabel.text = @"4 Minutes ago";
    //=================== TESTING ==================================
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - image positioning

- (void)calculateImagePositionForButton:(UIButton *)button
{
#warning unfinished!!!
    CGSize size = [button.titleLabel.text sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    UIImageView *imageView = (UIImageView *)[button viewWithTag:999];
    
}


@end
