//
//  Conversation.m
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "Conversation.h"
#import "Message.h"
@import Firebase;

@implementation Conversation

#pragma mark - SnapshotParser Implementation

- (instancetype)initWithSnapshot:(FIRDataSnapshot *)snapshot exception:(NSArray<NSString *> *)exceptions {
    self = [super init];
    if (self) {
        if ([snapshot hasChild:@"id"] && ![exceptions containsObject:@"id"]) {
            self.cid = [snapshot childSnapshotForPath:@"id"].value;
        }
        if ([snapshot hasChild:@"lastMessageID"] && ![exceptions containsObject:@"lastMessageID"]) {
            self.lastMessageID = [snapshot childSnapshotForPath:@"lastMessageID"].value;
        }
    }
    return self;
}

@end
