//
//  Message.h
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapshotParser.h"

@class User;

@interface Message : NSObject <SnapshotParser>

@property (nonatomic, copy) NSString *mid;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) id timestamp;


- (NSDictionary *)dictionaryValue;

@end
