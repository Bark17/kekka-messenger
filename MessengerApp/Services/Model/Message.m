//
//  Message.m
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "Message.h"
#import "User.h"
@import Firebase;


@implementation Message

#pragma mark - SnapshotParser Implementation

- (instancetype)initWithSnapshot:(FIRDataSnapshot *)snapshot exception:(NSArray<NSString *> *)exceptions {
    self = [super init];
    if (self) {
        if ([snapshot hasChild:@"id"] && ![exceptions containsObject:@"id"]) {
            self.mid = [snapshot childSnapshotForPath:@"id"].value;
        }
        if ([snapshot hasChild:@"userID"] && ![exceptions containsObject:@"userID"]) {
            self.userID = [snapshot childSnapshotForPath:@"userID"].value;
        }
        if ([snapshot hasChild:@"text"] && ![exceptions containsObject:@"text"]) {
            self.text = [snapshot childSnapshotForPath:@"text"].value;
        }
        if ([snapshot hasChild:@"timestamp"] && ![exceptions containsObject:@"timestamp"]) {
            self.timestamp = (NSNumber *)[snapshot childSnapshotForPath:@"timestamp"].value;
        }
    }
    return self;
}

#pragma mark - 
- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [@{} mutableCopy];
    if (self.mid) {
        dict[@"id"] = self.mid;
    }
    if (self.userID) {
        dict[@"userID"] = self.userID;
    } else if (self.user) {
        dict[@"userID"] = self.user.uid;
    }
    if (self.text) {
        dict[@"text"] = self.text;
    }
    if (self.timestamp) {
        dict[@"timestamp"] = self.timestamp;
    }
    return [dict copy];
}

@end














