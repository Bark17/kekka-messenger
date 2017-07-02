//
//  ProfileInfoTableViewCell.h
//  MessengerApp
//
//  Created by Vlad on 24.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileInfoViewModel, ProfileInfoTableViewCell;

@protocol ProfileInfoCellDelegate <NSObject>

- (void)didTapAvatarView;
- (void)didLongTapAvatarView;

@end

@interface ProfileInfoTableViewCell : UITableViewCell

@property (readonly, copy) NSString *nameFieldText;
@property (readonly, copy) NSString *phoneNumberFieldText;
@property (readonly, copy) NSString *emailFieldText;

@property (nonatomic, weak) id <ProfileInfoCellDelegate> delegate;

- (void)configureWithViewModel:(ProfileInfoViewModel *)viewModel;
- (void)enableTextFields;
- (void)disableTextFields;
- (void)resetNameTextField;
- (void)resetEmailTextField;
- (void)resetPhoneNumberTextField;
- (void)setNameTextFieldFirstResponder;

@end

