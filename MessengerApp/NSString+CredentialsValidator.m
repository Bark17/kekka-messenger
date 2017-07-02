//
//  NSString+CredentialsValidator.m
//  MessengerApp
//
//  Created by Vlad on 24.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "NSString+CredentialsValidator.h"

@implementation NSString (CredentialsValidator)

#pragma mark -
- (BOOL)isValidPhoneNumber {
    if (self.length < 11) {
        return NO;
    }
    NSString *phoneRegex = @"(\\+7|7|8)-?[0-9]{3}-?[0-9]{3}-?[0-9]{2}-?[0-9]{2}";
    NSPredicate *numberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [numberPredicate evaluateWithObject:self];
}

- (BOOL)isValidEmail {
    NSString *emailRegex = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:self];
}

- (BOOL)isValidPassword {
    if (self.length < 6) {
        return NO;
    }
    return YES;
}

@end
