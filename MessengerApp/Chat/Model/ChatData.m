//
//  ChatData.m
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ChatData.h"
#import "Conversation.h"


@implementation ChatData

#pragma mark - Initialization
- (instancetype)initWithConversationID:(NSString *)conversationID {
    self = [super init];
    if (self) {
        Conversation *conversation = [Conversation new];
        conversation.cid = conversationID;
        _conversation = conversation;
    }
    return self;
}

@end
