//
//  ProfileInfoViewModel.m
//  MessengerApp
//
//  Created by Vlad on 24.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ProfileInfoViewModel.h"
#import "User.h"


@interface ProfileInfoViewModel ()

@property (nonatomic, strong) User *model;

@end

@implementation ProfileInfoViewModel


#pragma mark - Initialization
- (instancetype)initWithModel:(User *)model {
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

#pragma mark - Getters
- (NSString *)userName {
    return self.model.name;
}

- (NSString *)userEmail {
    return self.model.email;
}

- (NSString *)userPhoneNumber {
    return self.model.phoneNumber;
}

- (NSURL *)userAvatarURL {
    return self.model.avatarURL;
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

@end
