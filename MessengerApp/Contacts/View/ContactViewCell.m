//
//  ContactViewCell.m
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ContactViewCell.h"
#import "ContactViewModel.h"
#import "AvatarView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ContactViewCell ()

@property (weak, nonatomic) IBOutlet AvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;


@end

@implementation ContactViewCell

#pragma mark -
- (void)awakeFromNib {
    [super awakeFromNib];
    
}

#pragma mark -
- (void)configureWithViewModel:(ContactViewModel *)viewModel {
    self.nameLabel.text = viewModel.name;
    self.emailLabel.text = viewModel.email;
    self.phoneLabel.text = viewModel.phoneNumber;
    self.avatarView.initialsLabel.text = viewModel.nameInitials;
    if (viewModel.avatarURL) {
        [self setAvatarImageFromURL:viewModel.avatarURL];
    } else {
        [self.avatarView setInitialsLabelType];
    }
    
}

- (void)setAvatarImageFromURL:(NSURL *)url {
    [self.avatarView.imageView sd_setImageWithURL:url];
    [self.avatarView setImageViewType];
}

@end
