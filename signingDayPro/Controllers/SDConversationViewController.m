//
//  SDConversationViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDConversationViewController.h"
#import "Message.h"
#import "User.h"
#import "SDChatService.h"

#import "NSString+Additions.h"
#import "SDMessageCell.h"
#import "MBProgressHUD.h"
#import "SDContentHeaderView.h"
#import "AFNetworking.h"
#import "DTCoreText.h"

#define ClearConversationButtonIndex 0

@interface SDConversationViewController ()

@property BOOL firstLoad;
@property (nonatomic, assign) int totalMessages;
@property (nonatomic, assign) int currentMessagesPage;

@end

@implementation SDConversationViewController

@synthesize enterMessageTextView = _enterMessageTextView;
@synthesize textViewBackgroundImageView = _textViewBackgroundImageView;
@synthesize conversation = _conversation;
@synthesize dataArray = _dataArray;
@synthesize chatBar = _chatBar;
@synthesize previousContentHeight = _previousContentHeight;
@synthesize sendButton = _sendButton;
@synthesize firstLoad = _firstLoad;
@synthesize containerView = _containerView;
@synthesize isNewConversation = _isNewConversation;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.firstLoad = YES;
    
    NSArray *users = [self.conversation.users allObjects];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    NSNumber *masterIdentifier = [self getMasterIdentifier];
    for (User *user in users) {
        if (![user.identifier isEqualToNumber:masterIdentifier])
            [names addObject:user.name];
    }
    
    //check if user hasn't writen a message to himself (was able in the previous versions of the app)
    if ([names count] == 0) {
        User *masterUser = [self getMasterUser];
        [names addObject:masterUser.name];
    }
    
    NSArray *sortedUsernames = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.contentHeaderView = [[SDContentHeaderView alloc] initWithFrame:CGRectMake(0, 44, 320, 40)];
    [self.view addSubview:self.contentHeaderView];
    
    self.contentHeaderView.textLabel.text = [sortedUsernames componentsJoinedByString:@", "];
    
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //reset messages
    _currentMessagesPage = _totalMessages = 0;
    if (!_isNewConversation) {
        if (self.firstLoad) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
            hud.labelText = @"Updating chat";
        }
        [self checkServer];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.isNewConversation && ![self.conversation.isRead boolValue]) {
        [SDChatService setConversationToRead:self.conversation completionBlock:^{
        }];
    }
    if (self.isNewConversation)
        [self.enterMessageTextView becomeFirstResponder];
}

- (void)loadMoreData
{
    _currentMessagesPage++;
    [self checkServer];
}

- (void)checkServer
{
    if (self.conversation.identifier) {
        
        [SDChatService getMessagesWithPageNumber:_currentMessagesPage fromConversation:self.conversation success:^(int totalMessagesCount) {
            
            _totalMessages = totalMessagesCount;
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
                [SDChatService deleteMarkedMessagesForConversation:self.conversation];
                [self reload];
                [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
                [self scrollToBottomAnimated:YES];
            }
            
        } failure:^{
            [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
        }];
    } else {
        self.firstLoad = NO;
    }
}

- (void)reload
{
    NSArray *unsortedMessages = [self.conversation.messages allObjects];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    self.dataArray = [unsortedMessages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
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
    
    if (!self.conversation.identifier) {
        NSString *username = [(User *)[[self.conversation.users allObjects] objectAtIndex:0] username];
        [SDChatService startNewConversationWithUsername:username text:rightTrimmedMessage completionBlock:^(NSString *identifier) {
            self.conversation.identifier = identifier;
            
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
            [self checkServer];
        }];
    } else {
        [SDChatService sendMessage:rightTrimmedMessage forConversation:self.conversation completionBlock:^{
            [self checkServer];
        }];
    }
    
    [self scrollToBottomAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    int count = [self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i++) {
        SDMessageCell *cell = (SDMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userImageView.image = nil;
    }
}

- (NSAttributedString *)getAttributedStringForTextViewFromMessage:(Message *)message
{
    NSData *HTMLData = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *builderOptions = @{DTDefaultFontFamily: @"Helvetica",
                                     DTUseiOS6Attributes: [NSNumber numberWithBool:YES]};
    DTHTMLAttributedStringBuilder *attributedStringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:HTMLData
                                                                                                         options:builderOptions
                                                                                              documentAttributes:nil];
    return [attributedStringBuilder generatedAttributedString];
}

#pragma mark - UITableView data source and delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    
    SDMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SDMessageCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    } else {
        [cell.userImageView cancelImageRequestOperation];
    }
    
    Message *message = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.messageTextView.attributedText = [self getAttributedStringForTextViewFromMessage:message];
    cell.usernameLabel.text = message.user.name;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:message.date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if ([today day] == [otherDay day] &&
        [today month] == [otherDay month] &&
        [today year] == [otherDay year] &&
        [today era] == [otherDay era]) {
        dateFormatter.dateFormat = @"hh:mm a";
    } else {
        dateFormatter.dateFormat = @"MMM dd";
    }
    
    cell.dateLabel.text = [dateFormatter stringFromDate:message.date];
    
    NSString *myUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    if ([message.user.username isEqual:myUsername]) {
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1];
    } else {
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:message.user.avatarUrl]];
    [cell.userImageView setImageWithURLRequest:request
                              placeholderImage:nil
                                 cropedForSize:CGSizeMake(50, 50)
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           SDMessageCell *myCell = (SDMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                           myCell.userImageView.image = image;
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           //
                                       }];
    
    [cell setNeedsLayout];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.dataArray objectAtIndex:indexPath.row];
    
    CGRect rect = [[self getAttributedStringForTextViewFromMessage:message] boundingRectWithSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                         context:nil];
    CGFloat height = rect.size.height + 31 + 13 - 16;
    if (height < 68) {
        height = 68;
    }
    return height;
}

@end
