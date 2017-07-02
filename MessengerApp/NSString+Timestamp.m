//
//  NSString+Timestamp.m
//  MessengerApp
//
//  Created by Vlad on 18.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "NSString+Timestamp.h"

@implementation NSString (Timestamp)

+ (NSString *)stringFromTimestamp:(NSNumber *)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue/1000];
    if (date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *stringDate = [formatter stringFromDate:date];
        return stringDate;
    }
    return @"";
}

@end
