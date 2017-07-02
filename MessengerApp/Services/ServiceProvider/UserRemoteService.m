//
//  UserServiceProvider.m
//  MessengerApp
//
//  Created by Vlad on 22.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "UserRemoteService.h"
#import <UIKit/UIKit.h>
#import "AuthSession.h"
#import "User.h"
@import Firebase;


@implementation UserRemoteService

- (void)updateUserInfo:(NSDictionary *)userInfo withCompletion:(UserUpdateInfoCompletionBlock)completion; {
    if (!userInfo) {
        completion(false);
        return;
    }
    NSString *newName = [userInfo objectForKey:@"name"];
    NSString *newPhoneNumber = [userInfo objectForKey:@"phoneNumber"];
    NSString *newEmail = [userInfo objectForKey:@"email"];
    NSMutableDictionary *updates = [@{} mutableCopy];
    NSString *currentUserPath = [NSString stringWithFormat:@"users/%@", AuthSession.currentSession.user.uid];
    FIRDatabaseReference *userRef = [[[FIRDatabase database] reference] child:currentUserPath];
    if (newName) {
        updates[@"name"] = newName;
    }
    if (newPhoneNumber) {
        updates[@"phoneNumber"] = newPhoneNumber;
    }
    if (newEmail) {
        updates[@"email"] = newEmail;
        [[[FIRAuth auth] currentUser] updateEmail:newEmail completion:^(NSError * _Nullable error) {
            if (error) {
                completion(false);
                return;
            }
            if (updates.count > 0) {
                [userRef updateChildValues:[updates copy] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    if (error) {
                        completion(false);
                        return;
                    }
                    completion(true);
                }];
            } else {
                completion(true);
            }
        }];
    } else {
        [userRef updateChildValues:[updates copy] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                completion(false);
                return;
            }
            completion(true);
        }];
    }
}

- (void)uploadAvatarImage:(UIImage *)avatarImage withCompletion:(UserUploadAvatarCompletionBlock)completion {
    if (!avatarImage) {
        completion(nil);
        return;
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/avatar.jpg", AuthSession.currentSession.user.uid];
    NSData *imageData = UIImageJPEGRepresentation(avatarImage, 0.4f);
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    [[storageRef child:filePath] deleteWithCompletion:^(NSError * _Nullable error) {
        [[storageRef child:filePath] putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (error) {
                completion(nil);
                return;
            }
            [[storageRef child:filePath] downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                if (URL) {
                    completion(URL);
                    return;
                }
                completion(nil);
            }];
        }];
    }];
}

- (void)deleteAvatarImageWithCompletion:(UserDeleteAvatarCompletionBlock)completion {
    NSString *filePath = [NSString stringWithFormat:@"%@/avatar.jpg", AuthSession.currentSession.user.uid];
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    [[storageRef child:filePath] deleteWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            completion(false);
            return;
        }
        completion(true);
    }];
}

@end




