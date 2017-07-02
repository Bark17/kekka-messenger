//
//  RegisterViewController.m
//  MessengerApp
//
//  Created by Vlad on 09.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "RegisterViewController.h"
#import "CredentialsTextField.h"
#import "AuthenticationRemoteService.h"
#import "User.h"
#import "NSString+Plus.h"
#import "MBProgressHUD.h"
#import "NSString+CredentialsValidator.h"
#import "AuthSession.h"
#import "UserRemoteService.h"
@import Photos;
@import Firebase;

@interface RegisterViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet CredentialsTextField *nameField;
@property (weak, nonatomic) IBOutlet CredentialsTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet CredentialsTextField *emailField;
@property (weak, nonatomic) IBOutlet CredentialsTextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *imagePickerButton;

#pragma mark - Properties
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) AuthenticationRemoteService *authService;
@property (nonatomic, strong) FIRStorageReference *storageRef;
@property (nonatomic, copy) NSURL *imageFile; // avatar image
@property (nonatomic, strong) UIImage *chosenImage;

@end

@implementation RegisterViewController

#pragma mark - 
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self setUpDelegates];
    self.storageRef = [[FIRStorage storage] reference];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Configuration
- (void)configureUI {
    self.imagePickerButton.layer.cornerRadius = self.imagePickerButton.bounds.size.height / 2.0;
    self.imagePickerButton.clipsToBounds = YES;
    self.registerButton.layer.cornerRadius = 5.0;
    self.registerButton.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.emailField resignFirstResponder];
    [self.nameField resignFirstResponder];
    [self.phoneNumberField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)setUpDelegates {
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    self.phoneNumberField.delegate = self;
    self.passwordField.delegate = self;
}

#pragma mark - Lazy initialization
- (AuthenticationRemoteService *)authService {
    if (!_authService) {
        _authService = [AuthenticationRemoteService new];
    }
    return _authService;
}

- (void)createUser {
    self.user = [User new];
    self.user.email = [self.emailField.text clearWhiteSpaces];
    self.user.phoneNumber = [self.phoneNumberField.text clearWhiteSpaces];
    self.user.name = [self.nameField.text clearWhiteSpaces];
    self.password = self.passwordField.text;
}

#pragma mark -
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements

- (UITextField *)currentTextField {
    if ([self.nameField isFirstResponder]) {
        return self.nameField;
    } else if ([self.phoneNumberField isFirstResponder]) {
        return self.phoneNumberField;
    } else if ([self.emailField isFirstResponder]) {
        return self.emailField;
    } else if ([self.passwordField isFirstResponder]) {
        return self.passwordField;
    } else {
        return nil;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    UITextField *currentTextField = [self currentTextField];
    if (!currentTextField) {
        return;
    }
    CGFloat bottomPointY = currentTextField.frame.origin.y + currentTextField.bounds.size.height;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat kbOffset = self.view.bounds.size.height - keyboardSize.height;
    if (kbOffset < bottomPointY) {
        CGFloat delta = bottomPointY - kbOffset + 20;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = -delta;
            self.view.frame = f;
        }];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.nameField isFirstResponder]) {
        [self.phoneNumberField becomeFirstResponder];
    } else if ([self.phoneNumberField isFirstResponder]) {
        [self.emailField becomeFirstResponder];
    } else if ([self.emailField isFirstResponder]) {
        [self.passwordField becomeFirstResponder];
    } else if ([self.passwordField isFirstResponder]) {
        [self.passwordField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Helpers
- (BOOL)isTextFieldsCorrect {
    NSString *name = [self.nameField.text clearWhiteSpaces];
    NSString *email = [self.emailField.text clearWhiteSpaces];
    NSString *phoneNumber = [self.phoneNumberField.text clearWhiteSpaces];
    NSString *password = self.passwordField.text;
    if (name.length > 0 && email.isValidEmail && phoneNumber.isValidPhoneNumber && password.isValidPassword) {
        return YES;
    }
    NSMutableArray *wrongFields = [@[] mutableCopy];
    if (!email.isValidEmail) {
        [self.emailField highlightWithRedBorder];
        [wrongFields addObject:@"E-mail"];
    }
    if (!password.isValidPassword) {
        [self.passwordField highlightWithRedBorder];
        [wrongFields addObject:@"Password"];
    }
    if (name.length == 0) {
        [self.nameField highlightWithRedBorder];
        [wrongFields addObject:@"Name"];
    }
    if (!phoneNumber.isValidPhoneNumber) {
        [self.phoneNumberField highlightWithRedBorder];
        [wrongFields addObject:@"Phone"];
    }
    NSString *joinedWrongFields = [wrongFields componentsJoinedByString:@", "];
    NSString *statusText = [NSString stringWithFormat:@"Check next fields: %@", joinedWrongFields];
    self.statusLabel.text = statusText;
    return NO;
}

#pragma mark - IBActions
- (IBAction)registerButtonAction:(id)sender {
    [self createUser];
    if (![self isTextFieldsCorrect]) {
        return;
    }
    self.statusLabel.text = @"";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak RegisterViewController *weakSelf = self;
    [self.authService registerUser:self.user
                          password:self.password
                        completion:^(User *user, NSError *error) {
                            __strong RegisterViewController *strongSelf = weakSelf;
                            if (user) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [strongSelf handleSuccessRegistration:user];
                                });
                            }
                            if (error) {
                                NSLog(@"Registration failed: %@", error.localizedDescription);
                                strongSelf.statusLabel.text = [NSString stringWithFormat:@"Failed: %@", error.localizedDescription];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                               [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                            });
                        }];
}

- (void)handleSuccessRegistration:(User *)user {
    NSLog(@"Registration success, userID: %@", user.uid);
    self.statusLabel.text = [NSString stringWithFormat:@"User has been created"];
    [AuthSession.currentSession configureWithUser:user];
    [self uploadAvatarImage];
    [self performSegueWithIdentifier:@"toMainSB" sender:nil];
}

#pragma mark - Image picker
- (IBAction)imagePickerButtonAction:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    NSURL *referenceUrl = info[UIImagePickerControllerReferenceURL];
    UIImage *chosenImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
    if (referenceUrl) {
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
        PHAsset *asset = assets.firstObject;
        [asset requestContentEditingInputWithOptions:nil
                                   completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                       NSDictionary *info) {
                                       self.imageFile = contentEditingInput.fullSizeImageURL;
                                       
                                   }];
        [self setChosenImageToPickButton:chosenImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
- (void)setChosenImageToPickButton:(UIImage *)image {
    if (image) {
        self.chosenImage = image;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.imagePickerButton.bounds.size.width, self.imagePickerButton.bounds.size.height)];
        [imageView setImage:image];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imagePickerButton addSubview:imageView];
        [self.imagePickerButton setEnabled:NO];
    }
}

#pragma mark - Uploading image
- (void)uploadAvatarImage {
    if (self.imageFile && self.chosenImage) {
        UserRemoteService *userService = [UserRemoteService new];
        [userService uploadAvatarImage:self.chosenImage withCompletion:^(NSURL *avatarURL) {
            [AuthSession.currentSession updateAvatarURL:avatarURL];
        }];
    }
}

#pragma mark - 
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



@end
