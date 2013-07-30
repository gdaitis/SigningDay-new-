//
//  SDConversationViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conversation.h"
#import "SDBaseChatViewController.h"

@interface SDConversationViewController : SDBaseChatViewController

@property (nonatomic, strong) Conversation *conversation;
@property BOOL isNewConversation;

@end
