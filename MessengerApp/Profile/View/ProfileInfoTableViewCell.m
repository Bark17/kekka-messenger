//
//  ProfileInfoTableViewCell.m
//  MessengerApp
//
//  Created by Vlad on 24.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ProfileInfoTableViewCell.h"
#import "ProfileInfoViewModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AvatarView.h"

@interface ProfileInfoTableViewCell ()

@property (weak, nonatomic) IBOutlet AvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (nonatomic, strong) ProfileInfoViewModel *viewModel;

@end


@implementation ProfileInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureAvatarView];
}

#pragma mark - Configuration
- (void)configureWithViewModel:(ProfileInfoViewModel *)viewModel {
    self.viewModel = viewModel;
    if (viewModel.userAvatarURL) {
        [self.avatarView setImageViewType];
        [self.avatarView.imageView sd_setImageWithURL:viewModel.userAvatarURL];
    } else {
        [self.avatarView setInitialsLabelType];
        self.avatarView.initialsLabel.text = viewModel.nameInitials;
    }
    self.nameTextField.text = viewModel.userName;
    self.phoneNumberTextField.text = viewModel.userPhoneNumber;
    self.emailTextField.text = viewModel.userEmail;
}

- (void)configureAvatarView {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarViewTap)];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarViewLongPress)];
    [self.avatarView addGestureRecognizer:tapGesture];
    [self.avatarView addGestureRecognizer:longPressGesture];
}

- (void)handleAvatarViewTap {
    if (self.delegate) {
        [self.delegate didTapAvatarView];
    }
}

- (void)handleAvatarViewLongPress {
    if (self.delegate && self.avatarView.imageView.image) {
        [self.delegate didLongTapAvatarView];
    }
}

#pragma mark - Getters
- (NSString *)nameFieldText {
    return self.nameTextField.text;
}

- (NSString *)phoneNumberFieldText {
    return self.phoneNumberTextField.text;
}

- (NSString *)emailFieldText {
    return self.emailTextField.text;
}

#pragma mark - Public
- (void)enableTextFields {
    self.nameTextField.enabled = YES;
    self.phoneNumberTextField.enabled = YES;
    self.emailTextField.enabled = YES;
}

- (void)disableTextFields {
    self.nameTextField.enabled = NO;
    self.phoneNumberTextField.enabled = NO;
    self.emailTextField.enabled = NO;
}

- (void)resetNameTextField {
    self.nameTextField.text = self.viewModel.userName;
}

- (void)resetEmailTextField {
    self.emailTextField.text = self.viewModel.userEmail;
}

- (void)resetPhoneNumberTextField {
    self.phoneNumberTextField.text = self.viewModel.userPhoneNumber;
}

- (void)setNameTextFieldFirstResponder {
    if ([self.nameTextField isEnabled]) {
        [self.nameTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
    }
}

@end
