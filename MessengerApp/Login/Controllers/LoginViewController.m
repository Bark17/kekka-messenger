//
//  LoginViewController.m
//  MessengerApp
//
//  Created by Vlad on 09.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "LoginViewController.h"
#import "CredentialsTextField.h"
#import "AuthenticationRemoteService.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "ContactsRemoteService.h"
#import "NSString+CredentialsValidator.h"
#import "AuthSession.h"
#import "UIColor+AppColors.h"

@interface LoginViewController () <UITextFieldDelegate>

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet CredentialsTextField *emailField;
@property (weak, nonatomic) IBOutlet CredentialsTextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

#pragma mark - Properties
@property (nonatomic, strong) AuthenticationRemoteService *authService;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

@end

@implementation LoginViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self setUpDelegates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Lazy initialization
- (AuthenticationRemoteService *)authService {
    if (!_authService) {
        _authService = [AuthenticationRemoteService new];
    }
    return _authService;
}

#pragma mark - Configuration

- (void)setUpDelegates {
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
}

- (void)configureUI {
    /* Login button */
    self.loginButton.layer.cornerRadius = 5.0;
    self.loginButton.clipsToBounds = YES;
    /* Dismiss kb on tap gesture */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}


- (void)setCredentials {
    self.email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.password = self.passwordField.text;
}

#pragma mark - IBActions
- (IBAction)loginButtonAction:(id)sender {
    [self setCredentials];
    if (![self isTextFieldsCorrect]) {
        return;
    }
    self.statusLabel.text = @"";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak LoginViewController *weakSelf = self;
    [self.authService loginWithEmail:self.email
                             password:self.password
                           completion:^(User *user, NSError *error) {
                               __strong LoginViewController *strongSelf = weakSelf;
                               if (user) {
                                   NSLog(@"Login success, username: %@", user.name);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [strongSelf handleSuccessAuth:user];
                                   });
                               }
                               if (error) {
                                   NSLog(@"Login error: %@", error.localizedDescription);
                                   strongSelf.statusLabel.text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                               });
                           }];
}

- (void)handleSuccessAuth:(User *)user {
    self.statusLabel.text = [NSString stringWithFormat:@"Auth success"];
    [AuthSession.currentSession configureWithUser:user];
    [self performSegueWithIdentifier:@"toMainSB" sender:nil];
}

#pragma mark - Helpers

- (BOOL)isTextFieldsCorrect {
    if (self.email.isValidEmail && self.password.isValidPassword) {
        return YES;
    }
    if (!self.email.isValidEmail) {
        [self.emailField highlightWithRedBorder];
    }
    if (!self.password.isValidPassword) {
        [self.passwordField highlightWithRedBorder];
    }
    return NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual: self.emailField]) {
        [self.passwordField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordField]) {
        [self.passwordField resignFirstResponder];
    }
    return YES;
}

#pragma mark -
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
