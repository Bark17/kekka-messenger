//
//  AuthenticationService.h
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

typedef void (^AuthenticationCompletionBlock)(User *user, NSError *error);

@protocol AuthenticationService <NSObject>

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(AuthenticationCompletionBlock)completion;
- (void)registerUser:(User *)user
            password:(NSString *)password
          completion:(AuthenticationCompletionBlock)completion;
- (void)logoutWithCompletion:(AuthenticationCompletionBlock)completion;

@end


