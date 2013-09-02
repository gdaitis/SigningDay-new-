//
//  SDActivityStoryViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 8/29/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityStoryViewController.h"
#import "ActivityStory.h"
#import "User.h"
#import "SDUtils.h"
#import "AFNetworking.h"
#import "SDActivityFeedCellContentView.h"
#import "SDUserProfileViewController.h"
#import "SDImageEnlargementView.h"

#import <MediaPlayer/MediaPlayer.h>

@interface SDActivityStoryViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet SDActivityFeedCellContentView *resizableActivityFeedView;

@property (weak, nonatomic) IBOutlet UIButton *playerNameButton;
@property (weak, nonatomic) IBOutlet UIButton *secondPlayerNameButton;

@property (strong, nonatomic) MPMoviePlayerViewController *player;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)mediaButtonPressed:(id)sender;


@end

@implementation SDActivityStoryViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect frame = self.resizableActivityFeedView.frame;
    frame.size.height = [SDUtils heightForActivityStory:self.activityStory forUITextView:self.resizableActivityFeedView.contentTextView]+12;
    self.resizableActivityFeedView.frame = frame;
    
#warning hardcoded value (for testing)
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, frame.size.height + 50);
    //[self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Setup

- (void)setupView
{
    [self.playerNameButton addTarget:self action:@selector(firstUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondPlayerNameButton addTarget:self action:@selector(secondUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.resizableActivityFeedView setActivityStory:self.activityStory];
    
    if ([self.activityStory.author.avatarUrl length] > 0) {
        [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:self.activityStory.author.avatarUrl]];
    }
    
    self.postDateLabel.text = [SDUtils formatedTimeForDate:self.activityStory.createdDate];
    [self setupNameLabelForActivityStory:self.activityStory];
}



- (void)setupNameLabelForActivityStory:(ActivityStory *)activityStory
{
    //this function setups attributed user name. If user has parameters adds them, also if activityStory is a wallpost adds arrows and appends other user name
    
    if (!activityStory)
        return;
    
    UIColor *firstColor = [UIColor colorWithRed:107.0f/255.0f green:93.0f/255.0f blue:0 alpha:1.0f];
    UIColor *secondColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    
    NSMutableAttributedString *authorName = nil;
    if (activityStory.postedToUser) {
        //this is a wall post
        
        //get first and second usernames with attributes
        User *user = activityStory.author;
        NSString *userName = [NSString stringWithFormat:@"%@ ",user.name];
        NSString *attributes = [SDUtils attributeStringForUser:user];
        
        NSMutableAttributedString *secondUserName = nil;
        User *secondUser = activityStory.postedToUser;
        NSString *secondUserAttributes = [SDUtils attributeStringForUser:secondUser];
        
        
        //form first user name and attributes
        if (attributes) {
            authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName firstColor:firstColor andSecondText:attributes andSecondColor:secondColor andFirstFont:[UIFont boldSystemFontOfSize:12] andSecondFont:[UIFont systemFontOfSize:12]]];
        }
        else {
            //nsattributed string just for name
            authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName andColor:firstColor andFont:[UIFont boldSystemFontOfSize:12]]];
        }
        
        
        //form second user name
        if (secondUserAttributes) {
            secondUserName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:secondUser.name firstColor:firstColor andSecondText:secondUserAttributes andSecondColor:secondColor andFirstFont:[UIFont boldSystemFontOfSize:12] andSecondFont:[UIFont systemFontOfSize:12]]];
        }
        else {
            //nsattributed string just for name
            secondUserName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:secondUser.name andColor:firstColor andFont:[UIFont boldSystemFontOfSize:12]]];
        }
        
        //flags to determin if name was clipped, if yes then we add "..." in the end
        BOOL firstStringClipped = NO;
        BOOL secondStringClipped = NO;
        
        //substring names to needed sizes
        while (authorName.mutableString.length + secondUserName.mutableString.length + 3 > kMaxNamesSymbolSize) {
            if (authorName.mutableString.length > secondUserName.mutableString.length) {
                authorName = (NSMutableAttributedString *)[authorName attributedSubstringFromRange:NSMakeRange(0, authorName.length-1)];
                firstStringClipped = YES;
            }
            else {
                secondStringClipped = YES;
                secondUserName = (NSMutableAttributedString *)[secondUserName attributedSubstringFromRange:NSMakeRange(0, secondUserName.length-1)];
            }
        }
        
        
        NSAttributedString *tripleDotString = [[NSAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:@"..." andColor:secondColor andFont:[UIFont systemFontOfSize:12]]];
        
        if (firstStringClipped) {
            [authorName appendAttributedString:tripleDotString];
        }
        
        //assign size for the player name buttons
        CGRect firstNameSize = [authorName boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        
        int buttonWidth = ceil(firstNameSize.size.width) + 40; //offset from photo; hardcoded for performance
        
        for (NSLayoutConstraint *constraint in self.playerNameButton.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                constraint.constant = buttonWidth;
                break;
            }
        }
        
        if (secondStringClipped) {
            [secondUserName appendAttributedString:tripleDotString];
        }
        
        //append arrow
        NSAttributedString *arrowString = [[NSAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:@" \u25B8 " andColor:secondColor andFont:[UIFont systemFontOfSize:12]]];
        [authorName appendAttributedString:arrowString];
        
        //apend name to the result
        [authorName appendAttributedString:secondUserName];
        
    }
    else {
        //simple post
        User *user = activityStory.author;
        NSString *userName = [NSString stringWithFormat:@"%@ ",user.name];
        
        NSString *attributes = [SDUtils attributeStringForUser:user];
        if (attributes) {
            authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName firstColor:firstColor andSecondText:attributes andSecondColor:secondColor andFirstFont:[UIFont boldSystemFontOfSize:12] andSecondFont:[UIFont systemFontOfSize:12]]];
        }
        else {
            //nsattributed string just for name
            authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName andColor:firstColor andFont:[UIFont boldSystemFontOfSize:12]]];
        }
        
        //only one user, player name button size cell.width
        for (NSLayoutConstraint *constraint in self.playerNameButton.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                constraint.constant = 286;
                break;
            }
        }
    }
    self.nameLabel.attributedText = authorName;
}


- (void)firstUserNameButtonPressed:(id)sender
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = self.activityStory.author;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)secondUserNameButtonPressed:(id)sender
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = self.activityStory.postedToUser;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

#pragma mark - Media logic

- (IBAction)mediaButtonPressed:(id)sender
{
    NSLog(@"self.activityStory.mediaType = %@",self.activityStory.mediaType);
    if (self.activityStory.mediaType) {
        if ([self.activityStory.mediaType isEqualToString:@"photos"]) {
            //photos
            //show enlarged image view
            [self showImageView];
        }
        else {
            //videos
            [self playVideo];
        }
    }
}

- (void)showImageView
{
    SDImageEnlargementView *imageEnlargemenetView = [[SDImageEnlargementView alloc] initWithFrame:self.view.frame andImage:self.activityStory.mediaUrl];
    [imageEnlargemenetView presentImageViewInView:self.navigationController.view];
}

- (void)playVideo
{
    NSURL *url = [NSURL URLWithString:self.activityStory.mediaUrl];
    
    self.player = [[MPMoviePlayerViewController alloc] init];
    [self.player.moviePlayer setContentURL:url];
    self.player.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.player.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [self.player.view setFrame:self.view.bounds];
    [self.player.moviePlayer prepareToPlay];

    [self presentMoviePlayerViewControllerAnimated:self.player];
    [self.player.moviePlayer play];
}

//- (void)moviePlayBackDonePressed:(NSNotification*)notification
//{
//    [self.player.moviePlayer stop];
//    
////    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player.moviePlayer];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:self.player.moviePlayer];
//    
//    if ([self.player.moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
//    {
//        [self.player.moviePlayer.view removeFromSuperview];
//    }
//    self.player = nil;
//}

//- (void) moviePlayBackDidFinish:(NSNotification*)notification
//{
//    [self.player.moviePlayer stop];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:self.player.moviePlayer];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player.moviePlayer];
//
//    if ([self.player.moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
//    {
//        [self.player.moviePlayer.view removeFromSuperview];
//    }
//}


@end
