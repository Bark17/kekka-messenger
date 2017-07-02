//
//  User.m
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "User.h"
#import "UserMO+CoreDataClass.h"
@import Firebase;

@implementation User


#pragma mark - SnapshotParser Implementation
- (instancetype)initWithSnapshot:(FIRDataSnapshot *)snapshot exception:(NSArray<NSString *> *)exceptions {
    self = [super init];
    if (self) {
        if ([snapshot hasChild:@"id"] && ![exceptions containsObject:@"id"]) {
            self.uid = [snapshot childSnapshotForPath:@"id"].value;
        }
        if ([snapshot hasChild:@"email"] && ![exceptions containsObject:@"email"]) {
            self.email = [snapshot childSnapshotForPath:@"email"].value;
        }
        if ([snapshot hasChild:@"name"] && ![exceptions containsObject:@"name"]) {
            self.name = [snapshot childSnapshotForPath:@"name"].value;
        }
        if ([snapshot hasChild:@"phoneNumber"] && ![exceptions containsObject:@"phoneNumber"]) {
            self.phoneNumber = [snapshot childSnapshotForPath:@"phoneNumber"].value;
        }
    }
    return self;
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject {
    self = [super init];
    if (self) {
        if ([managedObject isKindOfClass:[UserMO class]]) {
            UserMO *userMO = (UserMO *)managedObject;
            self.uid = userMO.uid;
            self.email = userMO.email;
            self.name = userMO.name;
            self.phoneNumber = userMO.phoneNumber;
            NSString *avatarUrlString = userMO.avatarUrlString;
            if (avatarUrlString) {
                NSURL *avatarURL = [NSURL URLWithString:avatarUrlString];
                self.avatarURL = avatarURL;
            }
        }
    }
    return self;
}


@end
