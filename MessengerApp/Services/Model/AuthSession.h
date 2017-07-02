//
//  AuthSession.h
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface AuthSession : NSObject


/**
 Current user session
 */
+ (instancetype)currentSession;

/**
 Current user
 user.id only
 */
@property (nonatomic, strong) User *user;
@property (readonly) BOOL isValid;

- (void)configureWithUser:(User *)user;
- (void)saveCurrentUser;

@end
