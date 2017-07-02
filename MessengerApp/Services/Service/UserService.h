//
//  UserService.h
//  MessengerApp
//
//  Created by Vlad on 22.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UserUpdateInfoCompletionBlock)(BOOL updated);
typedef void (^UserUploadAvatarCompletionBlock)(NSURL *avatarURL);
typedef void (^UserDeleteAvatarCompletionBlock)(BOOL result);

@class UIImage;

@protocol UserService <NSObject>

- (void)updateUserInfo:(NSDictionary *)userInfo withCompletion:(UserUpdateInfoCompletionBlock)completion;
- (void)uploadAvatarImage:(UIImage *)avatarImage withCompletion:(UserUploadAvatarCompletionBlock)completion;
- (void)deleteAvatarImageWithCompletion:(UserDeleteAvatarCompletionBlock)completion;

@end
