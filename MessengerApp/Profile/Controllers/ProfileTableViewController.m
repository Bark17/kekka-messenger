//
//  ProfileTableViewController.m
//  MessengerApp
//
//  Created by Vlad on 24.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "ProfileInfoTableViewCell.h"
#import "ProfileInfoViewModel.h"
#import "AuthSession.h"
#import "UserRemoteService.h"
#import "User.h"
#import "NSString+CredentialsValidator.h"
#import "MBProgressHUD.h"
#import "AuthenticationRemoteService.h"
#import "AppDelegate.h"
@import Photos;

@interface ProfileTableViewController () <ProfileInfoCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet ProfileInfoTableViewCell *profileInfoCell;

#pragma mark - Properties
@property (nonatomic, strong) ProfileInfoViewModel *profileInfoViewModel;

@end

@implementation ProfileTableViewController {
    BOOL _isDeleteAlertControllerPresented;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configure];
}

#pragma mark - Configuration
- (void)configure {
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelection = NO;
    [self configureProfileInfoCell];
}

- (void)configureProfileInfoCell {
    AuthSession *currentSession = [AuthSession currentSession];
    if (currentSession.isValid) {
        User *currentUser = currentSession.user;
        self.profileInfoViewModel = [[ProfileInfoViewModel alloc] initWithModel:currentUser];
        self.profileInfoCell.delegate = self;
        [self.profileInfoCell configureWithViewModel:self.profileInfoViewModel];
        if (self.isEditing) {
            [self.profileInfoCell enableTextFields];
        } else {
            [self.profileInfoCell disableTextFields];
        }
    }
}

#pragma mark -
- (IBAction)logoutAction:(id)sender {
    UIAlertController *logoutAlertController = [UIAlertController alertControllerWithTitle:@"Log out" message:@"Are you sure about that?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        AuthenticationRemoteService *authService = [AuthenticationRemoteService new];
        [authService logoutWithCompletion:^(User *user, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [logoutAlertController dismissViewControllerAnimated:YES completion:nil];
                UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                UIViewController *rootLoginVC = [loginSB instantiateInitialViewController];
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [UIView transitionWithView:appDelegate.window
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    appDelegate.window.rootViewController = rootLoginVC;
                                }
                                completion:nil];
            });
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [logoutAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [logoutAlertController addAction:deleteAction];
    [logoutAlertController addAction:cancelAction];
    [self presentViewController:logoutAlertController animated:YES completion:nil];
}


#pragma mark -
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (self.isEditing) {
        [self.profileInfoCell enableTextFields];
        [self prepareForEdit];
    } else {
        [self.profileInfoCell disableTextFields];
        [self commitChangesFromProfileInfoCell];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return @"";
    }
    if (self.isEditing) {
        return @"Your info (Editing)";
    } else {
        return @"Your info";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section != 0) {
        return @"";
    }
    if (self.isEditing && self.profileInfoViewModel.userAvatarURL) {
        return @"Long press on avatar to delete.";
    }
    return @"";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)prepareForEdit {
    [self.profileInfoCell setNameTextFieldFirstResponder];
}

#pragma mark -
- (void)commitChangesFromProfileInfoCell {
    BOOL userNameChanged = ![self.profileInfoViewModel.userName isEqualToString:self.profileInfoCell.nameFieldText];
    BOOL userPhoneNumberChanged = ![self.profileInfoViewModel.userPhoneNumber isEqualToString:self.profileInfoCell.phoneNumberFieldText];
    BOOL userEmailChanged = ![self.profileInfoViewModel.userEmail isEqualToString:self.profileInfoCell.emailFieldText];
    NSMutableDictionary *newUserInfo = [@{} mutableCopy];
    if (userNameChanged) {
        NSString *newName = self.profileInfoCell.nameFieldText;
        if (newName.length < 1) {
            [self.profileInfoCell resetNameTextField];
        } else {
            newUserInfo[@"name"] = newName;
        }
    }
    if (userPhoneNumberChanged) {
        NSString *newPhoneNumber = self.profileInfoCell.phoneNumberFieldText;
        if (!newPhoneNumber.isValidPhoneNumber) {
            [self.profileInfoCell resetPhoneNumberTextField];
        } else {
            newUserInfo[@"phoneNumber"] = newPhoneNumber;
        }
    }
    if (userEmailChanged) {
        NSString *newEmail = self.profileInfoCell.emailFieldText;
        if (!newEmail.isValidEmail) {
            [self.profileInfoCell resetEmailTextField];
        } else {
            newUserInfo[@"email"] = newEmail;
        }
    }
    if (newUserInfo.count > 0) {
        UserRemoteService *userService = [UserRemoteService new];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [userService updateUserInfo:[newUserInfo copy] withCompletion:^(BOOL updated) {
            if (updated) {
                NSString *newName = newUserInfo[@"name"];
                NSString *newEmail = newUserInfo[@"email"];
                NSString *newPhoneNumber = newUserInfo[@"phoneNumber"];
                if (newName) {
                    AuthSession.currentSession.user.name = newName;
                }
                if (newEmail) {
                    AuthSession.currentSession.user.email = newEmail;
                }
                if (newPhoneNumber) {
                    AuthSession.currentSession.user.phoneNumber = newPhoneNumber;
                }
                self.profileInfoViewModel = [[ProfileInfoViewModel alloc] initWithModel:AuthSession.currentSession.user];
                [self.profileInfoCell configureWithViewModel:self.profileInfoViewModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.profileInfoCell resetNameTextField];
                    [self.profileInfoCell resetEmailTextField];
                    [self.profileInfoCell resetPhoneNumberTextField];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text = @"Done";
                [hud hideAnimated:YES afterDelay:0.5];
            });
        }];
    }
}



#pragma mark - ProfileInfoCellDelegate
- (void)didTapAvatarView {
    if (!self.isEditing) {
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)didLongTapAvatarView {
    if (!self.isEditing || _isDeleteAlertControllerPresented) {
        return;
    }
    UIAlertController *deleteAlertController = [UIAlertController alertControllerWithTitle:@"Deleting avatar" message:@"Are you sure about that?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        UserRemoteService *userService = [UserRemoteService new];
        [userService deleteAvatarImageWithCompletion:^(BOOL result) {
            if (result) {
                [AuthSession.currentSession updateAvatarURL:nil];
                self.profileInfoViewModel = [[ProfileInfoViewModel alloc] initWithModel:AuthSession.currentSession.user];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.profileInfoCell configureWithViewModel:self.profileInfoViewModel];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            _isDeleteAlertControllerPresented = NO;
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [deleteAlertController dismissViewControllerAnimated:YES completion:nil];
        _isDeleteAlertControllerPresented = NO;
    }];
    [deleteAlertController addAction:deleteAction];
    [deleteAlertController addAction:cancelAction];
    [self presentViewController:deleteAlertController animated:YES completion:nil];
    _isDeleteAlertControllerPresented = YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *chosenImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
    if (chosenImage) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        UserRemoteService *userService = [UserRemoteService new];
        [userService uploadAvatarImage:chosenImage withCompletion:^(NSURL *avatarURL) {
            if (avatarURL) {
                [AuthSession.currentSession updateAvatarURL:avatarURL];
                self.profileInfoViewModel = [[ProfileInfoViewModel alloc] initWithModel:AuthSession.currentSession.user];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.profileInfoCell configureWithViewModel:self.profileInfoViewModel];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}




@end
