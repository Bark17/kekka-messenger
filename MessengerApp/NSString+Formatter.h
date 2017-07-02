//
//  NSString+Formatter.h
//  MessengerApp
//
//  Created by Vlad on 27.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Formatter)

/* Phone Number */
- (NSString *)defaultPhoneNumberFormat;
- (NSString *)prettyPhoneNumberFormat;
- (NSString *)phoneNumberWithoutFirstDigit;

@end
