//
//  MessagesServiceProvider.m
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "MessagesRemoteService.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#import "AuthSession.h"
@import Firebase;

@interface MessagesRemoteService ()

@property (nonatomic, weak) AuthSession *authSession;
@property (nonatomic, weak) Conversation *conversation;
@property (nonatomic, strong) FIRDatabaseReference *rootRef;
@property (nonatomic, strong) FIRDatabaseReference *conversationMessagesRef;

@end


@implementation MessagesRemoteService

#pragma mark - Initialization
- (instancetype)initWithConversation:(Conversation *)conversation
                      andAuthSession:(AuthSession *)session {
    self = [super init];
    if (self) {
        self.conversation = conversation;
        self.authSession = session;
    }
    return self;
}

#pragma mark - Getters
- (FIRDatabaseReference *)rootRef {
    if (!_rootRef) {
        _rootRef = [[FIRDatabase database] reference];
    }
    return _rootRef;
}

- (FIRDatabaseReference *)conversationMessagesRef {
    if (!_conversationMessagesRef) {
        NSString *messagesPath = [NSString stringWithFormat:@"messages/%@", self.conversation.cid];
        _conversationMessagesRef = [self.rootRef child:messagesPath];
    }
    return _conversationMessagesRef;
}

#pragma mark - 
- (void)obtainMessagesWithLimit:(NSUInteger)limit
                         offset:(NSString *)offset
             andCompletionBlock:(MessagesCompletionBlock)completion {
    FIRDatabaseQuery *query = [self.conversationMessagesRef queryOrderedByKey];
    if (offset) {
        query = [query queryStartingAtValue:offset];
    }
    //
    [query observeSingleEventOfType:FIRDataEventTypeValue
          withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
              if (!(snapshot.childrenCount > 0)) {
                  completion(@[], nil);
                  return;
              }
              NSMutableArray *messages = [@[] mutableCopy];
              for (FIRDataSnapshot *child in snapshot.children) {
                  if (!child) {
                      continue;
                  }
                  NSString *messageID = child.key;
                  FIRDatabaseReference *messageRef = [self.conversationMessagesRef child:messageID];
                  //
                  [messageRef observeSingleEventOfType:FIRDataEventTypeValue
                     withBlock:^(FIRDataSnapshot * _Nonnull messageSnapshot) {
                         if (![messageSnapshot.value isEqual:[NSNull null]]) {
                             Message *m = [[Message alloc] initWithSnapshot:messageSnapshot exception:nil];
                             NSString *userPath = [NSString stringWithFormat:@"users/%@",m.userID];
                             FIRDatabaseReference *userRef = [self.rootRef child:userPath];
                             //
                             [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull userSnapshot) {
                                 if (![userSnapshot.value isEqual:[NSNull null]]) {
                                     User *u = [[User alloc] initWithSnapshot:userSnapshot exception:nil];
                                     m.user = u;
                                     [messages addObject:m];
                                     if (messages.count == snapshot.childrenCount) {
                                         completion(messages, nil);
                                     }
                                 }
                             }];
                         }
                     }];
              }
          }];
    
}

- (void)sendMessage:(Message *)message withCompletionBlock:(SendMessageCompletionBlock)completion {
    FIRDatabaseReference *newMesageRef = [self.conversationMessagesRef childByAutoId];
    NSString *mid = newMesageRef.key;
    message.mid = mid;
    message.timestamp = FIRServerValue.timestamp;
    NSDictionary *updates = [message dictionaryValue];
    [newMesageRef updateChildValues:updates
                withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    if (error) {
                        completion(false);
                        return;
                    }
                    NSDictionary *conversationUpdates = @{@"lastMessageID" : ref.key};
                    NSString *conversationPath = [NSString stringWithFormat:@"conversations/%@", self.conversation.cid];
                    [[self.rootRef child:conversationPath] updateChildValues:conversationUpdates withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                        completion(true);
                    }];
                }];
}

- (void)removeAllObservers {
    [self.conversationMessagesRef removeAllObservers];
}

@end















