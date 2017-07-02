//
//  NSString+CredentialsValidator.h
//  MessengerApp
//
//  Created by Vlad on 24.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CredentialsValidator)

- (BOOL)isValidPhoneNumber;
- (BOOL)isValidEmail;
- (BOOL)isValidPassword;

@end
