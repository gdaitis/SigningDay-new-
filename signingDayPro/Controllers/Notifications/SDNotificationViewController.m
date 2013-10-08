//
//  SDNotificationViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/20/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNotificationViewController.h"
#import "User.h"
#import "SDContentHeaderView.h"
#import "Notification.h"
#import "SDNotificationsService.h"
#import "SDNotificationCell.h"
#import "UIImageView+Crop.h"
#import "SDUtils.h"
#import "SDActivityFeedService.h"
#import "ActivityStory.h"
#import "SDUserProfileViewController.h"
#import "SDProfileService.h"

@interface SDNotificationViewController ()

@property BOOL firstLoad;

@end

@implementation SDNotificationViewController

- (id)init
{
    self = [super initWithNibName:@"SDBaseToolbarItemViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.firstLoad = YES;
    
    SDContentHeaderView *contentHeaderView = [[SDContentHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    contentHeaderView.textLabel.text = @"Notifications";
    contentHeaderView.textLabel.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1];
    [self.view addSubview:contentHeaderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadInfo
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
        [self reloadView];
    }
    if (self.firstLoad) {
        //[self showProgressHudInView:self.view withText:@"Updating conversations"];
        [self beginRefreshing];
    }
    [self checkServer];
}

- (void)reloadView
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [self getMaster];
    NSPredicate *masterPredicate = [NSPredicate predicateWithFormat:@"master == %@", master];
    NSPredicate *notificationTypesPredicate = [NSPredicate predicateWithFormat:@"notificationTypeId == %d OR notificationTypeId == %d OR notificationTypeId == %d", SDNotificationTypeLike, SDNotificationTypeComment, SDNotificationTypeFollowing];
    NSPredicate *contentTypeNamesPredicate = [NSPredicate predicateWithFormat:@"contentTypeName == %@ OR contentTypeName == %@ OR contentTypeName == %@ OR contentTypeName == %@", @"Comment", @"Wall Post", @"Status Message", @"Following"];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[masterPredicate, notificationTypesPredicate, contentTypeNamesPredicate]];
    self.dataArray = [Notification MR_findAllSortedBy:@"createdDate"
                                            ascending:NO
                                        withPredicate:compoundPredicate
                                            inContext:context];
    [self.tableView reloadData];
}

- (void)checkServer
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
        [SDNotificationsService getNotificationsWithPageSize:[NSNumber numberWithInteger:30]
                                                successBlock:^{
                                                    [self reloadView];
                                                    [self endRefreshing];
                                                    [SDNotificationsService markAllNotificationsReadWithSuccessBlock:^{
                                                        [self.delegate notificationViewControllerDidCheckForNewNotifications:self];
                                                    } failureBlock:nil];
                                                } failureBlock:^{
                                                    [self endRefreshing];
                                                }];
    }
}

- (NSString *)getNotificationStringFromNotification:(Notification *)notification
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                 fromDate:notification.createdDate];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                              fromDate:[NSDate date]];
    if ([today day] == [otherDay day] &&
        [today month] == [otherDay month] &&
        [today year] == [otherDay year] &&
        [today era] == [otherDay era]) {
        dateFormatter.dateFormat = @"hh:mm a";
    } else {
        dateFormatter.dateFormat = @"MMM dd";
    }
    
    NSString *dateString = [dateFormatter stringFromDate:notification.createdDate];
    NSString *notificationStringSentence = @"";
    
    SDNotificationType notificationType = [notification.notificationTypeId integerValue];
    switch (notificationType) {
        case SDNotificationTypeLike:
            notificationStringSentence = [NSString stringWithFormat:@"likes your %@", notification.contentTypeName];
            break;
            
        case SDNotificationTypeComment:
            notificationStringSentence = [NSString stringWithFormat:@"commented on your %@", notification.contentTypeName];
            break;
            
        case SDNotificationTypeForumReply:
            notificationStringSentence = [NSString stringWithFormat:@"replied to your Forum Post"];
            break;
            
        case SDNotificationTypeMention:
            notificationStringSentence = [NSString stringWithFormat:@"mentioned you in his, %@", notification.contentTypeName];
            break;
            
        case SDNotificationTypeForumPost:
            notificationStringSentence = [NSString stringWithFormat:@"posted to your Forum Thread"];
            break;
            
        case SDNotificationTypeFollowing:
            notificationStringSentence = [NSString stringWithFormat:@"is following you"];
            break;
            
        case SDNotificationTypeBuzzBoard:
            notificationStringSentence =[NSString stringWithFormat: @"posted on your Buzz Board"];
            break;
            
        default:
            break;
    }
    
    NSString *notificationTitleString = [NSString stringWithFormat:@"%@ %@\n%@", notification.fromUser.name, notificationStringSentence, dateString];
    
    return notificationTitleString;
}

#pragma mark - TableView datasource and delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDNotificationCell *cell = nil;
    NSString *cellIdentifier = @"NotificationCell";
    
    cell = (SDNotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Load cell
        NSArray *topLevelObjects = nil;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDNotificationCell" owner:nil options:nil];
        // Grab cell reference which was set during nib load:
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDNotificationCell class]]) {
                cell = currentObject;
                break;
            }
        }
        cell.backgroundColor = [UIColor clearColor];
    } else {
        [cell.cellImageView cancelImageRequestOperation];
    }
    
    Notification *notification = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.labelText = [self getNotificationStringFromNotification:notification];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:notification.fromUser.avatarUrl]];
    [cell.cellImageView setImageWithURLRequest:request
                              placeholderImage:nil
                                 cropedForSize:CGSizeMake(50, 50)
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           SDNotificationCell *myCell = (SDNotificationCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                           myCell.cellImageView.image = image;
                                           
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           //
                                       }];
    
    if ([notification.isNew boolValue])
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:236.0f/255.0f
                                                              green:232.0f/255.0f
                                                               blue:208.0f/255.0f
                                                              alpha:1];
    else
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    
    [cell setNeedsLayout];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Notification *notification = [self.dataArray objectAtIndex:indexPath.row];
    if ([notification.notificationTypeId isEqualToNumber:[NSNumber numberWithInteger:SDNotificationTypeFollowing]]) {
        
        if ([notification.fromUser.userTypeId intValue] != SDUserTypeOrganization && [notification.fromUser.userTypeId intValue] != SDUserTypeNFLPA && [notification.fromUser.userTypeId intValue] > 0) {
            //user shouldn't be from NFLPA or Organizations
            [self.delegate notificationViewController:self
                                        didSelectUser:notification.fromUser];
        }
        else {
            [self showAlertWithTitle:nil andText:@"Sorry, this profile is currently unavailable."];
        }
    }
    if (notification.activityStoryId) {
        [self beginRefreshing];
        [SDActivityFeedService getActivityStoryWithContentId:notification.activityStoryId
                                                successBlock:^{
                                                    [self endRefreshing];
                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                    ActivityStory *activityStory = [ActivityStory MR_findFirstByAttribute:@"identifier"
                                                                                                                withValue:notification.activityStoryId
                                                                                                                inContext:context];
                                                    if (activityStory)
                                                        [self.delegate notificationViewController:self
                                                                           didSelectActivityStory:activityStory];
                                                } failureBlock:^{
                                                    [self endRefreshing];
                                                }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *notification = [self.dataArray objectAtIndex:indexPath.row];
    NSString *notificationString = [self getNotificationStringFromNotification:notification];
    CGSize maxSize = CGSizeMake(256, CGFLOAT_MAX);
    CGSize expectedSize = [notificationString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]
                                         constrainedToSize:maxSize
                                             lineBreakMode:NSLineBreakByWordWrapping];
    int height = expectedSize.height + 6 + 8;
    if (height < 44)
        return 44;
    return height;
}

@end
