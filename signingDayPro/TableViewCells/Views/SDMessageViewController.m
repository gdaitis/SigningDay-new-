//
//  SDMessageViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDMessageViewController.h"

#import "SDAppDelegate.h"
#import "SDChatService.h"

#import "Conversation.h"
#import "User.h"
#import "SDConversationCell.h"
#import "AFNetworking.h"
#import "SDConversationViewController.h"
#import "SDContentHeaderView.h"
#import "SDAPIClient.h"

@interface SDMessageViewController ()

@property (nonatomic, assign) int totalMessages;
@property (nonatomic, assign) int currentMessagesPage;
@property BOOL firstLoad;

- (void)reloadView;
- (void)checkServer;

@end

@implementation SDMessageViewController

- (id)init
{
    //self = [super initWithNibName:@"SDBaseToolbarItemViewController" bundle:[NSBundle mainBundle]];
    UIStoryboard *messagesStoryboard = [UIStoryboard storyboardWithName:@"MessagesStoryboard"
                                                                 bundle:nil];
    self = [messagesStoryboard instantiateViewControllerWithIdentifier:@"messagesViewController"];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServer) name:kSDPushNotificationReceivedWhileInBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServer) name:kSDPushNotificationReceivedWhileInForegroundNotification object:nil];
    
    self.firstLoad = YES;
    _currentMessagesPage = _totalMessages = 0;
    
    SDContentHeaderView *contentHeaderView = [[SDContentHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    contentHeaderView.textLabel.text = @"Conversations";
    contentHeaderView.textLabel.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"NewConversationButtonImage.png"];
    btn.frame = CGRectMake(288, 8, img.size.width, img.size.height);
    [btn setImage:img forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startNewConversation) forControlEvents:UIControlEventTouchUpInside];
    [contentHeaderView addSubview:btn];
    [self.view addSubview:contentHeaderView];
}

- (void)loadInfo
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
        [self reloadView];
    }
    if (self.firstLoad) {
        [self showProgressHudInView:self.view withText:@"Updating conversations"];
    }
    [self checkServer];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    int count = [self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i++) {
        SDConversationCell *cell = (SDConversationCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userImageView.image = nil;
    }
}

- (void)reloadView
{
    NSString *string = nil;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"])
        string = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"master.username like %@", string];
    self.dataArray = [Conversation MR_findAllSortedBy:@"lastMessageDate"
                                            ascending:NO
                                        withPredicate:predicate
                                            inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [self.tableView reloadData];
}

- (void)loadMoreData
{
    _currentMessagesPage++;
    [self checkServer];
}

- (void)checkServer
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
        
        [SDChatService getConversationsForPage:_currentMessagesPage withSuccessBlock:^(int totalConversationCount) {
            _totalMessages = totalConversationCount;
            
            //if there are more conversations, we need to download them
            if ((_currentMessagesPage+1)*kMaxItemsPerPage < _totalMessages )
            {
                [self loadMoreData];
            }
            else {
                if (self.firstLoad) {
                    self.firstLoad = NO;
                }
                //delete old messages
                [SDChatService deleteMarkedConversations];
                
                [self reloadView];
                [self hideProgressHudInView:self.view];
            }
            
        } failureBlock:^{
            [self hideProgressHudInView:self.view];
        }];
    }
}

#pragma mark - TableView datasource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDConversationCell *cell = nil;
    NSString *cellIdentifier = @"ConversationCell";
    
    cell = (SDConversationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Load cell
        NSArray *topLevelObjects = nil;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDConversationCell" owner:nil options:nil];
        // Grab cell reference which was set during nib load:
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDConversationCell class]]) {
                cell = currentObject;
                break;
            }
        }
    }
    
    cell.userImageView.image = nil;
    
    Conversation *conversation = [self.dataArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:conversation.lastMessageDate];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if ([today day] == [otherDay day] &&
        [today month] == [otherDay month] &&
        [today year] == [otherDay year] &&
        [today era] == [otherDay era]) {
        dateFormatter.dateFormat = @"hh:mm a";
    } else {
        dateFormatter.dateFormat = @"MMM dd";
    }
    
    cell.dateLabel.text = [dateFormatter stringFromDate:conversation.lastMessageDate];
    cell.messageTextLabel.text = conversation.lastMessageText;
    
    NSArray *users = [conversation.users allObjects];
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    for (User *user in users) {
        if (![user.username isEqual:masterUsername])
            [usernames addObject:user.username];
    }
    
    NSArray *sortedUsernames = [usernames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    cell.usernameLabel.text = [sortedUsernames componentsJoinedByString:@", "];
    
    User *conversationUser;
    if ([users count] == 1)
        conversationUser = [users objectAtIndex:0];
    else
        conversationUser = conversation.author;
    
    cell.userImageUrlString = conversationUser.avatarUrl;
    
    BOOL isRead = [conversation.isRead boolValue];
    if (!isRead)
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:232.0f/255.0f blue:208.0f/255.0f alpha:1];
    else
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Conversation *conversation = [self.dataArray objectAtIndex:indexPath.row];
    [self.delegate messageViewController:self
                   didSelectConversation:conversation];
}

#pragma mark - Actions

- (void)startNewConversation
{
//    SDNavigationController *newConversationNavigationController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"NewConversationNavigationController"];
//    newConversationNavigationController.myDelegate = self;
//    [self presentModalViewController:newConversationNavigationController animated:YES];
}

@end
