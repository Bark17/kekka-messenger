//
//  ContactsService.h
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, AuthSession;

typedef void (^ContactsCompletionBlock)(NSArray <User *> *contacts, NSError *error);
typedef void (^ContactsAddCompletionBlock)(NSError *error);
typedef void (^ContactsDeleteCompletionBlock)(NSError *error);
typedef void (^ContactsSearchCompletionBlock)(NSArray <User *> *contacts, NSError *error);
typedef void (^ContactsConversationCompletionBlock)(NSString *conversationID);

@protocol ContactsService <NSObject>

- (instancetype)initWithSession:(AuthSession *)session;

- (void)obtainAllUsers:(void (^)(NSArray <User *> *contacts, NSError *error))completion;
- (void)obtainContactListWithCompletion:(ContactsCompletionBlock)completion;
- (void)addContact:(User *)contact withCompletion:(ContactsAddCompletionBlock)completion;
- (void)deleteContact:(User *)contact withCompletion:(ContactsDeleteCompletionBlock)completion;
- (void)searchContacts:(NSString *)query withCompletion:(ContactsSearchCompletionBlock)completion;
- (void)obtainConversationWithContact:(User *)contact withCompletion:(ContactsConversationCompletionBlock)completion;

@end
