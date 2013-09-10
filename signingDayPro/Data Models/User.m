//
//  User.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/9/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "User.h"
#import "ActivityStory.h"
#import "Coach.h"
#import "Comment.h"
#import "Conversation.h"
#import "HighSchool.h"
#import "Like.h"
#import "Master.h"
#import "Member.h"
#import "Message.h"
#import "Player.h"
#import "Team.h"


@implementation User

@dynamic avatarUrl;
@dynamic bio;
@dynamic followerRelationshipCreated;
@dynamic followingRelationshipCreated;
@dynamic identifier;
@dynamic name;
@dynamic numberOfFollowers;
@dynamic numberOfFollowing;
@dynamic numberOfPhotos;
@dynamic numberOfVideos;
@dynamic username;
@dynamic userType;
@dynamic userTypeId;
@dynamic accountVerified;
@dynamic activityStories;
@dynamic activityStoriesFromOtherUsers;
@dynamic authorOf;
@dynamic comments;
@dynamic conversations;
@dynamic followedBy;
@dynamic following;
@dynamic likes;
@dynamic master;
@dynamic messages;
@dynamic theCoach;
@dynamic theHighSchool;
@dynamic theMember;
@dynamic thePlayer;
@dynamic theTeam;

@end
