//
//  NSString+Formatter.m
//  MessengerApp
//
//  Created by Vlad on 27.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "NSString+Formatter.h"
#import "NSString+CredentialsValidator.h"

@implementation NSString (Formatter)

- (NSString *)phoneNumberByRemovingExtraCharacters {
    NSString *number = [self copy];
    number = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    return number;
}

- (NSString *)defaultPhoneNumberFormat {
    NSString *number = [self phoneNumberByRemovingExtraCharacters];
    return number;
}

- (NSString *)prettyPhoneNumberFormat {
    NSString *number = [self defaultPhoneNumberFormat];
    if (number.length < 11) {
        return number;
    }
    NSString *code = @"";
    if ([[number substringToIndex:1] isEqualToString:@"7"]) {
        code = @"+7";
    } else {
        code = @"8";
    }
    NSString *firstThreeDigits = [[number substringFromIndex:1] substringToIndex:3];
    NSString *secondThreeDigits = [[number substringFromIndex:4] substringToIndex:3];
    NSString *firstTwoDigits = [[number substringFromIndex:7] substringToIndex:2];
    NSString *secondTwoDigits = [[number substringFromIndex:9] substringToIndex:2];
    return [NSString stringWithFormat:@"%@ (%@) %@-%@-%@", code, firstThreeDigits, secondThreeDigits, firstTwoDigits, secondTwoDigits];
}

- (NSString *)phoneNumberWithoutFirstDigit {
    NSString *number = [self defaultPhoneNumberFormat];
    if (number.length < 11) {
        return number;
    }
    return [number substringFromIndex:1];
}

@end
