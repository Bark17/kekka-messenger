//
//  ContactsServiceProvider.m
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ContactsRemoteService.h"
#import "AuthSession.h"
#import "User.h"
@import Firebase;

@interface ContactsRemoteService ()

@property (nonatomic, weak) AuthSession *session;

@end

@implementation ContactsRemoteService

#pragma mark - Initialization
- (instancetype)initWithSession:(AuthSession *)session {
    self = [super init];
    if (self) {
        self.session = session;
    }
    return self;
}

#pragma mark - 
- (NSString *)currentUserContactsPath {
    return [NSString stringWithFormat:@"user-contacts/%@", self.session.user.uid];
}


- (void)obtainAllUsers:(void (^)(NSArray<User *> *, NSError *))completion {
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[[ref child:@"users"] queryOrderedByKey] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableArray *tmp = [@[] mutableCopy];
        for (FIRDataSnapshot *userSnapshot in snapshot.children) {
            User *user = [[User alloc] initWithSnapshot:userSnapshot exception:nil];
            FIRStorageReference *storageRef = [[FIRStorage storage] reference];
            NSString *avatarPath = [NSString stringWithFormat:@"%@/avatar.jpg", user.uid];
            [[storageRef child:avatarPath] downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                if (URL) {
                    user.avatarURL = URL;
                }
                [self obtainConversationWithContact:user withCompletion:^(NSString *conversationID) {
                    if (conversationID) {
                        user.cid = conversationID;
                    }
                    [tmp addObject:user];
                    if (tmp.count == snapshot.childrenCount) {
                        completion(tmp, nil);
                        return;
                    }
                }];
            }];
            //
        }
        if ([snapshot.value isEqual:[NSNull null]]) {
            completion(tmp, nil);
        }
    }];
}


- (void)obtainContactListWithCompletion:(ContactsCompletionBlock)completion {
    if (!self.session.isValid) {
        completion(nil, nil);
        return;
    }
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[ref child:[self currentUserContactsPath]] observeSingleEventOfType:FIRDataEventTypeValue
       withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
           NSArray *contactIDs = snapshot.value;
           if ([contactIDs isEqual:[NSNull null]]) {
               completion(@[], nil);
               return;
           }
           NSMutableArray *contacts = [@[] mutableCopy];
           for (NSString *contactID in contactIDs) {
               NSString *userPath = [NSString stringWithFormat:@"users/%@", contactID];
               [[ref child:userPath] observeSingleEventOfType:FIRDataEventTypeValue
                  withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                      User *c = [[User alloc] initWithSnapshot:snapshot exception:nil];
                      if (!c) {
                          completion(nil, nil);
                          return;
                      }
                      //
                      FIRStorageReference *storageRef = [[FIRStorage storage] reference];
                      NSString *avatarPath = [NSString stringWithFormat:@"%@/avatar.jpg", c.uid];
                      [[storageRef child:avatarPath] downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                          if (URL) {
                              c.avatarURL = URL;
                          }
                          [self obtainConversationWithContact:c withCompletion:^(NSString *conversationID) {
                              if (conversationID) {
                                  c.cid = conversationID;
                              }
                              [contacts addObject:c];
                              if (contacts.count == contactIDs.count) {
                                  completion(contacts, nil);
                                  return;
                              }
                          }];
                      }];
                      //
                  }];
           }
       }];
}

- (void)addContact:(User *)contact withCompletion:(ContactsAddCompletionBlock)completion {
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
       [[ref child:[self currentUserContactsPath]] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
           NSArray *contactIDs = (NSArray *)currentData.value;
           if (![contactIDs isEqual:[NSNull null]]) {
               if ([contactIDs containsObject:contact.uid]) {
                   return [FIRTransactionResult successWithValue:currentData];
               } else {
                   NSArray *newContactIDs = [contactIDs arrayByAddingObject:contact.uid];
                   currentData.value = newContactIDs;
                   return [FIRTransactionResult successWithValue:currentData];
               }
           } else {
               currentData.value = @[contact.uid];
               return [FIRTransactionResult successWithValue:currentData];
           }
       } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
           if (error) {
               completion(error);
               return;
           }
           completion(nil);
       }];
}

- (void)deleteContact:(User *)contact withCompletion:(ContactsDeleteCompletionBlock)completion {
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[ref child:[self currentUserContactsPath]] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSArray *contactIDs = (NSArray *)currentData.value;
        if (![contactIDs isEqual:[NSNull null]]) {
            if ([contactIDs containsObject:contact.uid]) {
                NSMutableArray *newContactIDs = [contactIDs mutableCopy];
                [newContactIDs removeObject:contact.uid];
                currentData.value = [newContactIDs copy];
                return [FIRTransactionResult successWithValue:currentData];
            } else {
                NSArray *newContactIDs = [contactIDs arrayByAddingObject:contact.uid];
                currentData.value = newContactIDs;
                return [FIRTransactionResult successWithValue:currentData];
            }
        } else {
            return [FIRTransactionResult successWithValue:currentData];
        }
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        if (error) {
            completion(error);
            return;
        }
        completion(nil);
    }];
}

- (void)searchContacts:(NSString *)query withCompletion:(ContactsSearchCompletionBlock)completion {
    //
    // Firebase search doesn't work as it should in this project
    //
}

- (void)obtainConversationWithContact:(User *)contact withCompletion:(ContactsConversationCompletionBlock)completion {
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    NSString *currentUserConversationsPath = [NSString stringWithFormat:@"user-conversations/%@", self.session.user.uid];
    NSString *contactConversationsPath = [NSString stringWithFormat:@"user-conversations/%@", contact.uid];
    [[ref child:currentUserConversationsPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (![snapshot.value isEqual:[NSNull null]]) {
            NSArray *currentUserCids = snapshot.value;
            [[ref child:contactConversationsPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull contactSnapshot) {
                if (![contactSnapshot.value isEqual:[NSNull null]]) {
                    NSArray *contactCids = contactSnapshot.value;
                    NSMutableSet *currentUserCidsSet = [NSMutableSet setWithArray:currentUserCids];
                    NSSet *contactCidsSet = [NSSet setWithArray:contactCids];
                    [currentUserCidsSet intersectSet:contactCidsSet];
                    NSArray *conversations = [currentUserCidsSet allObjects];
                    if (conversations.count > 0) {
                        completion((NSString *)conversations.firstObject);
                    } else {
                        completion(nil);
                    }
                } else {
                    completion(nil);
                }
            }];
        } else {
            completion(nil);
        }
    }];
}

@end









