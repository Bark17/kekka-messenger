//
//  ContactViewModel.m
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ContactViewModel.h"
#import "User.h"
#import "NSString+Formatter.h"
@import Firebase;

@interface ContactViewModel ()

@property (nonatomic, strong) User *model;

@end

@implementation ContactViewModel

#pragma mark - Initialization
- (instancetype)initWithModel:(User *)model {
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

- (void)setConversationIDToModel:(NSString *)cid {
    self.model.cid = cid;
}

#pragma mark - Getters
- (NSString *)name {
    if ([FIRAuth.auth.currentUser.uid isEqualToString:self.model.uid]) {
        return [NSString stringWithFormat:@"%@ (YOU)", self.model.name];
    }
    return self.model.name;
}

- (NSString *)email {
    return [NSString stringWithFormat:@"%@", self.model.email];
}

- (NSString *)phoneNumber {
    return [[NSString stringWithFormat:@"%@", self.model.phoneNumber] prettyPhoneNumberFormat];
}

- (NSString *)nameInitials {
    NSArray *splitName = [self.model.name componentsSeparatedByString:@" "];
    if (splitName.count == 1) {
        NSString *firstName = [splitName objectAtIndex:0];
        NSString *firstLetter = firstName.length > 1 ? [firstName substringToIndex:1] : @"";
        return [firstLetter uppercaseString];
    } else if (splitName.count >= 2) {
        NSString *firstName = [splitName objectAtIndex:0];
        NSString *lastName = [splitName objectAtIndex:1];
        NSString *firstLetter = firstName.length > 1 ? [firstName substringToIndex:1] : @"";
        NSString *secondLetter = lastName.length > 1 ? [lastName substringToIndex:1] : @"";
        return [NSString stringWithFormat:@"%@%@", [firstLetter uppercaseString], [secondLetter uppercaseString]];
    }
    return @"";
}

- (NSURL *)avatarURL {
    return self.model.avatarURL;
}

- (NSString *)uid {
    return self.model.uid;
}

- (NSString *)conversationID {
    return self.model.cid;
}

@end














