//
//  AuthenticationServiceProvider.m
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "AuthenticationRemoteService.h"
#import "User.h"
#import "AuthSession.h"
@import Firebase;


@implementation AuthenticationRemoteService

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(AuthenticationCompletionBlock)completion {
    FIRAuth *auth = [FIRAuth auth];
    if (!auth) {
        NSLog(@"Authentication not found");
        completion(nil, [NSError new]);
        return;
    }
    [auth signInWithEmail:email
                 password:password
               completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                   if (error) {
                       NSLog(@"Auth error: %@", error.localizedDescription);
                       completion(nil, error);
                       return;
                   }
                   if (!user) {
                       NSLog(@"User not found");
                       completion(nil, error);
                       return;
                   }
                   
                   NSString *uid = user.uid;
                   FIRDatabaseReference *ref = [[FIRDatabase database] reference];
                   NSString *path = [NSString stringWithFormat:@"users/%@",uid];
                   [[ref child:path] observeSingleEventOfType:FIRDataEventTypeValue
                                                    withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                                        User *u = [[User alloc] initWithSnapshot:snapshot exception:nil];
                                                        FIRStorageReference *storageRef = [[FIRStorage storage] reference];
                                                        NSString *avatarPath = [NSString stringWithFormat:@"%@/avatar.jpg", u.uid];
                                                        [[storageRef child:avatarPath] downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                                            if (URL) {
                                                                u.avatarURL = URL;
                                                            }
                                                            completion(u, nil);
                                                        }];
                                                    }];
                   
                 }];
    
}

- (void)registerUser:(User *)user
            password:(NSString *)password
          completion:(AuthenticationCompletionBlock)completion {
    FIRAuth *auth = [FIRAuth auth];
    if (!auth) {
        NSLog(@"Authentication not found");
        completion(nil, [NSError new]);
        return;
    }
    
    [auth createUserWithEmail:user.email
                     password:password
                   completion:^(FIRUser * _Nullable u, NSError * _Nullable error) {
                       if (error) {
                           NSLog(@"Register error: %@", error.localizedDescription);
                           completion(nil, error);
                           return;
                       }
                       if (!u) {
                           NSLog(@"Register: user not found");
                           completion(nil, error);
                           return;
                       }
                       NSString *uid = u.uid;
                       NSMutableDictionary *userInfo = [@{@"id" : uid,
                                                  @"email" : user.email,
                                                  @"name" : user.name,
                                                  @"phoneNumber" : user.phoneNumber} mutableCopy];
                       FIRDatabaseReference *ref = [[FIRDatabase database] reference];
                       NSString *path = [NSString stringWithFormat:@"users/%@",uid];
                       [[ref child:path] setValue:[userInfo copy] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                           if (error) {
                               completion(nil, error);
                               return;
                           }
                           user.uid = uid;
                           completion(user, nil);
                       }];
                       
                   }];
}

- (void)logoutWithCompletion:(AuthenticationCompletionBlock)completion {
    FIRAuth *auth = [FIRAuth auth];
    if (!auth) {
        NSLog(@"Authentication not found");
        completion(nil, [NSError new]);
        return;
    }
    NSError *e = nil;
    [auth signOut:&e];
    if (e) {
        NSLog(@"Log out error: %@", e.localizedDescription);
        completion(nil, e);
    } else {
        AuthSession.currentSession.user = [User new];
        NSLog(@"Log out completed");
        completion(nil, nil);
    }
}

@end















