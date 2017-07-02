//
//  ConversationService.h
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conversation, AuthSession, User;

typedef void (^ConversationCompletionBlock)(NSArray <Conversation *> *conversations, NSError *error);
typedef void (^ConversationStartCompletionBlock)(Conversation *conversation, NSError *error);

@protocol ConversationService <NSObject>

- (instancetype)initWithSession:(AuthSession *)session;

- (void)obtainConversationListWithCompletionBlock:(ConversationCompletionBlock)completion;
- (void)startConversationWithUser:(User *)user completionBlock:(ConversationStartCompletionBlock)completion;

@end
