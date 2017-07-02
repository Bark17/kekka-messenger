//
//  MessagesService.h
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conversation, Message, AuthSession;

typedef void (^MessagesCompletionBlock)(NSArray <Message *> *messages, NSError *error);
typedef void (^SendMessageCompletionBlock)(BOOL sent);

@protocol MessagesService <NSObject>

- (instancetype)initWithConversation:(Conversation *)conversation andAuthSession:(AuthSession *)session;

- (void)obtainMessagesWithLimit:(NSUInteger)limit
                         offset:(NSString *)offset
             andCompletionBlock:(MessagesCompletionBlock)completion;
- (void)sendMessage:(Message *)message withCompletionBlock:(SendMessageCompletionBlock)completion;

@end
