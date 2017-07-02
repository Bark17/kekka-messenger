//
//  NSString+Plus.m
//  MessengerApp
//
//  Created by Vlad on 10.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "NSString+Plus.h"

@implementation NSString (Plus)

- (NSString *)clearWhiteSpaces {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
