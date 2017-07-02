//
//  NSString+Timestamp.h
//  MessengerApp
//
//  Created by Vlad on 18.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Timestamp)

+ (NSString *)stringFromTimestamp:(NSNumber *)timestamp;

@end
