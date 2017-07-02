//
//  Conversation.h
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapshotParser.h"

@class Message, User;

@interface Conversation : NSObject <SnapshotParser>

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSArray <User *> *members; // TODO
@property (nonatomic, copy) NSString *lastMessageID;
@property (nonatomic, strong) Message *lastMessage;

@end
