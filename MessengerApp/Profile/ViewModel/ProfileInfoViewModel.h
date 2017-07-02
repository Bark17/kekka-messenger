//
//  ProfileInfoViewModel.h
//  MessengerApp
//
//  Created by Vlad on 24.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface ProfileInfoViewModel : NSObject

@property (readonly, copy) NSString *userName;
@property (readonly, copy) NSString *userPhoneNumber;
@property (readonly, copy) NSString *userEmail;
@property (readonly, copy) NSURL *userAvatarURL;
@property (readonly, copy) NSString *nameInitials;
           
#pragma mark -
- (instancetype)initWithModel:(User *)model;


@end
