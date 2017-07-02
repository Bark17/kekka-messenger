//
//  ConversationsServiceProvider.m
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ConversationsRemoteService.h"
#import "Conversation.h"
#import "AuthSession.h"
#import "User.h"
#import "Message.h"
@import Firebase;

@interface ConversationsRemoteService ()

@property (nonatomic, weak) AuthSession *session;

@end

@implementation ConversationsRemoteService

#pragma mark - Initialization
- (instancetype)initWithSession:(AuthSession *)session {
    self = [super init];
    if (self) {
        self.session = session;
    }
    return self;
}



#pragma mark - Private
- (NSString *)currentUserConversationsPath {
    return [NSString stringWithFormat:@"user-conversations/%@", self.session.user.uid];
}

- (NSString *)pathForConversationWithID:(NSString *)cid {
    return [NSString stringWithFormat:@"conversations/%@", cid];
}

- (NSString *)pathForMessagesWithConversationID:(NSString *)cid {
    return [NSString stringWithFormat:@"messages/%@", cid];
}

- (NSString *)pathForUserWithID:(NSString *)uid {
    return [NSString stringWithFormat:@"users/%@", uid];
}

#pragma mark -
- (void)obtainConversationListWithCompletionBlock:(ConversationCompletionBlock)completion {
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    // user-conversations/<user-id>
    [[ref child:[self currentUserConversationsPath]] observeSingleEventOfType:FIRDataEventTypeValue
        withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSArray *conversationIDs = snapshot.value;
            if (![conversationIDs isEqual:[NSNull null]]) {
                NSMutableArray *conversations = [@[] mutableCopy];
                for (NSString *cid in conversationIDs) {
                    // conversations/<cid>
                    [[ref child:[self pathForConversationWithID:cid]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                        Conversation *conversation = [[Conversation alloc] initWithSnapshot:snapshot exception:nil];
                        // messages/<cid>/<lastMessageID>
                        [[[ref child:[self pathForMessagesWithConversationID:cid]] child:conversation.lastMessageID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull mSnapshot) {
                            Message *lastMessage = [[Message alloc] initWithSnapshot:mSnapshot exception:nil];
                            // users/<lastMessage.user-id>
                            if (lastMessage.userID) {
                                [[ref child:[self pathForUserWithID:lastMessage.userID]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                    User *user = [[User alloc] initWithSnapshot:snapshot exception:nil];
                                    lastMessage.user = user;
                                    conversation.lastMessage = lastMessage;
                                    [conversations addObject:conversation];
                                    if (conversations.count == conversationIDs.count) {
                                        completion(conversations, nil);
                                        return;
                                    }
                                }];
                            } else {
                                conversation.lastMessage = lastMessage;
                                [conversations addObject:conversation];
                                if (conversations.count == conversationIDs.count) {
                                    completion(conversations, nil);
                                    return;
                                }
                            }
                        }];
                        
                    }];
                }
            } else {
                completion(nil, nil);
            }
        }];
}

- (void)startConversationWithUser:(User *)user completionBlock:(ConversationStartCompletionBlock)completion {
    FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
    FIRDatabaseReference *conversationRef = [[rootRef child:@"conversations"] childByAutoId];
    NSDictionary *updates = @{@"id" : conversationRef.key,
                              @"users" : @{@"0" : self.session.user.uid,
                                           @"1" : user.uid}};
    [conversationRef updateChildValues:updates withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (!error) {
            NSString *currentUserConversationsPath = [NSString stringWithFormat:@"user-conversations/%@", self.session.user.uid];
            NSString *receiverUserConversationPath = [NSString stringWithFormat:@"user-conversations/%@", user.uid];
            [[rootRef child:currentUserConversationsPath] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                NSArray *cids = currentData.value;
                if (![cids isEqual:[NSNull null]]) {
                    NSArray *newCids = [cids arrayByAddingObject:ref.key];
                    currentData.value = newCids;
                } else {
                    currentData.value = @[ref.key];
                }
                [[rootRef child:receiverUserConversationPath] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull userData) {
                    NSArray *userCids = userData.value;
                    if (![userCids isEqual:[NSNull null]]) {
                        NSArray *newUserCids = [userCids arrayByAddingObject:ref.key];
                        userData.value = newUserCids;
                    } else {
                        userData.value = @[ref.key];
                    }
                    return [FIRTransactionResult successWithValue:userData];
                }];
                return [FIRTransactionResult successWithValue:currentData];
            }];
            NSLog(@"Conversation has been created");
            Conversation *c = [[Conversation alloc] init];
            c.cid = ref.key;
            completion(c, nil);
            return;
        }
        completion(nil, nil);
    }];
}

@end








