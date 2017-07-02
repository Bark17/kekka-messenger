//
//  ContactViewModel.h
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface ContactViewModel : NSObject

@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *email;
@property (readonly, copy) NSString *phoneNumber;
@property (readonly, copy) NSString *nameInitials;
@property (readonly, copy) NSURL *avatarURL;
@property (readonly, copy) NSString *uid;
@property (readonly, copy) NSString *conversationID;

- (instancetype)initWithModel:(User *)model;

- (void)setConversationIDToModel:(NSString *)cid;

@end
