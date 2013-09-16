//
//  Conversation.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/16/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "Conversation.h"
#import "Master.h"
#import "Message.h"
#import "User.h"


@implementation Conversation

@dynamic identifier;
@dynamic isRead;
@dynamic lastMessageDate;
@dynamic lastMessageText;
@dynamic shouldBeDeleted;
@dynamic author;
@dynamic master;
@dynamic messages;
@dynamic users;

@end
