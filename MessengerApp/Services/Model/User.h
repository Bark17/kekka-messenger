//
//  User.h
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapshotParser.h"
#import "ManagedObjectParser.h"

@interface User : NSObject <SnapshotParser, ManagedObjectParser>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSURL *avatarURL;

@end
