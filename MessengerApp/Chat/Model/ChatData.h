//
//  ChatData.h
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Message, Conversation, ContactViewModel;

@interface ChatData : NSObject

@property (nonatomic, strong) Conversation *conversation;
@property (nonatomic, strong) NSMutableArray <Message *> *messages;
@property (nonatomic, weak) ContactViewModel *userViewModel;

- (instancetype)initWithConversationID:(NSString *)conversationID;

@end
