//
//  ContactsViewController.m
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactViewModel.h"
#import "ContactViewCell.h"
#import "ContactsRemoteService.h"
#import "AuthSession.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "Conversation.h"
#import "ChatData.h"
#import "ChatViewController.h"
#import "ConversationsRemoteService.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NSString+Formatter.h"
#import <SDImageCache.h>
@import Contacts;

static NSString *const contactCellIdentifier = @"contactCell";

@interface ContactsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

#pragma mark - Properties
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ContactsRemoteService *contactsService;
@property (nonatomic, strong) ConversationsRemoteService *conversationsService;
@property (nonatomic, copy) NSArray <ContactViewModel *> *viewModels;
@property (nonatomic, copy) NSDictionary *addressBookNumbers;
@property (nonatomic, copy) NSArray <ContactViewModel *> *addressBookViewModels;
@property (nonatomic, copy) NSArray <ContactViewModel *> *searchResults;

@end

@implementation ContactsViewController {
    BOOL _isLoadingUsers;
    CNAuthorizationStatus _contactsAuthorizationStatus;
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self setUpDelegates];
    [self fetchAllUsers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - Configuration
- (void)setUpDelegates {
    /* Table View */
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    /* Search Controller */
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
}

- (void)configureUI {
    self.title = @"Contacts";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tabBarController.definesPresentationContext = YES;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    [self.searchController.searchBar setScopeBarBackgroundImage:[UIImage new]];
    self.searchController.searchBar.scopeButtonTitles = @[@"All", @"Address book"];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    /* Back button */
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - Lazy instantiation
- (ContactsRemoteService *)contactsService {
    if (!_contactsService) {
        _contactsService = [[ContactsRemoteService alloc] initWithSession:AuthSession.currentSession];
    }
    return _contactsService;
}

- (ConversationsRemoteService *)conversationsService {
    if (!_conversationsService) {
        _conversationsService = [[ConversationsRemoteService alloc] initWithSession:AuthSession.currentSession];
    }
    return _conversationsService;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    }
    return _searchController;
}


#pragma mark - Fetching
- (void)fetchAllUsers {
    self.viewModels = @[];
    _isLoadingUsers = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak ContactsViewController *weakSelf = self;
    [self.contactsService obtainAllUsers:^(NSArray<User *> *contacts, NSError *error) {
        __strong ContactsViewController *strongSelf = weakSelf;
        if (!contacts || !(contacts.count > 0)) {
            _isLoadingUsers = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            });
            return;
        }
        NSMutableArray *tmp = [@[] mutableCopy];
        NSMutableArray *ips = [@[] mutableCopy];
        NSInteger i = 0;
        for (User *contact in contacts) {
            ContactViewModel *vm = [[ContactViewModel alloc] initWithModel:contact];
            if (![vm.uid isEqualToString:AuthSession.currentSession.user.uid]) {
                [tmp addObject:vm];
                [ips addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                i += 1;
            }
        }
        _isLoadingUsers = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (strongSelf.viewModels.count == 0) {
                strongSelf.viewModels = [tmp copy];
                [UIView transitionWithView:strongSelf.tableView
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [strongSelf.tableView reloadData];
                                } completion:nil];
            }
        });
    }];
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return self.searchResults.count;
    } else {
        return self.viewModels.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCellIdentifier
                                                            forIndexPath:indexPath];
    ContactViewModel *viewModel = nil;
    if (self.searchController.isActive) {
        viewModel = self.searchResults.count > indexPath.row ? self.searchResults[indexPath.row] : nil;
    } else {
        viewModel = self.viewModels.count > indexPath.row ? self.viewModels[indexPath.row] : nil;
    }
    [cell configureWithViewModel:viewModel];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.viewModels.count) {
        return;
    }
    ContactViewModel *vm = nil;
    if (self.searchController.isActive) {
        vm = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        vm = [self.viewModels objectAtIndex:indexPath.row];
    }
    if (vm.conversationID) {
        ChatData *chatData = [[ChatData alloc] initWithConversationID:vm.conversationID];
        chatData.userViewModel = vm;
        [self segueToChatViewControllerWithChatData:chatData];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        User *user = [User new];
        user.uid = vm.uid;
        __weak ContactsViewController *weakSelf = self;
        [self.conversationsService startConversationWithUser:user completionBlock:^(Conversation *conversation, NSError *error) {
            __strong ContactsViewController *strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            });
            if (conversation) {
                [vm setConversationIDToModel:conversation.cid];
                ChatData *chatData = [[ChatData alloc] initWithConversationID:vm.conversationID];
                chatData.userViewModel = vm;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf segueToChatViewControllerWithChatData:chatData];
                });
            }
        }];
    }
}

- (void)segueToChatViewControllerWithChatData:(ChatData *)chatData {
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.chatData = chatData;
    chatVC.hidesBottomBarWhenPushed = YES;
    if (self.searchController.isActive) {
        [self.searchController.searchBar setText:@""];
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
    }
    [[self navigationController] pushViewController:chatVC animated:YES];
}

#pragma mark - Search
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    NSInteger selectedScope = searchController.searchBar.selectedScopeButtonIndex;
    if (searchText.length == 0) {
        self.searchResults = [self.addressBookViewModels copy];
        [self.tableView reloadData];
    } else {
        [self searchForText:[searchText lowercaseString] selectedScope:selectedScope];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if (selectedScope == 0) {
        self.searchResults = [self.viewModels copy];
        [self.tableView reloadData];
    } else if (selectedScope == 1) {
        if (!self.addressBookViewModels) {
            [self fetchContactsFromAddressBook];
        }
        self.searchResults = [self.addressBookViewModels copy];
        [self.tableView reloadData];
    }
}

- (void)searchForText:(NSString *)searchText selectedScope:(NSInteger)selectedScope {
    if (selectedScope == 0) {
        self.searchResults = [[self.viewModels copy] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ContactViewModel *vm, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [[vm.name lowercaseString] containsString:searchText] || [[[vm.phoneNumber defaultPhoneNumberFormat] lowercaseString] containsString:[searchText defaultPhoneNumberFormat]];
        }]];
    } else if (selectedScope == 1) {
        self.searchResults = [[self.addressBookViewModels copy] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ContactViewModel *vm, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [[vm.name lowercaseString] containsString:searchText] || [[[vm.phoneNumber defaultPhoneNumberFormat] lowercaseString] containsString:[searchText defaultPhoneNumberFormat]];
        }]];
    }
    [self.tableView reloadData];
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.selectedScopeButtonIndex == 1) {
        self.searchResults = [self.addressBookViewModels copy];
        [self.tableView reloadData];
    } else if (searchController.searchBar.selectedScopeButtonIndex == 0 && [searchController.searchBar.text isEqualToString:@""]) {
        self.searchResults = [self.viewModels copy];
        [self.tableView reloadData];
    }
}

#pragma mark - Fetching contacts from address book
- (void)fetchContactsFromAddressBook {
    [self checkAddressBookContactsAuthorizationStatus];
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // TODO: User didn't grant access
            });
            return;
        }
        NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
        NSString *containerId = store.defaultContainerIdentifier;
        NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
        NSError *err;
        NSArray *contacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&err];
        
        NSMutableDictionary *contactNumbersAndNames = [@{} mutableCopy];
        for (CNContact *contact in contacts) {
            NSString *fullName = @"";
            NSString *phone = @"";
            NSString *firstName = contact.givenName;
            NSString *lastName = contact.familyName;
            if (lastName == nil) {
                fullName = [NSString stringWithFormat:@"%@",firstName];
            } else if (firstName == nil) {
                fullName = [NSString stringWithFormat:@"%@",lastName];
            } else {
                fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
            }
            for (CNLabeledValue *label in contact.phoneNumbers) {
                phone = [[label.value stringValue] phoneNumberWithoutFirstDigit];
                if ([phone length] > 0) {
                    contactNumbersAndNames[phone] = fullName;
                }
            }
        }
        self.addressBookNumbers = [contactNumbersAndNames copy];
        [self findContactsFromAddressBook];
    }];
}

- (void)checkAddressBookContactsAuthorizationStatus {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Access to contacts." message:@"This app requires access to contacts because ..." preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    _contactsAuthorizationStatus = status;
}

- (NSArray *)findContactsFromAddressBook {
    if (!self.addressBookNumbers) {
        return nil;
    }
    NSArray *filteredContacts = [self.viewModels copy];
    filteredContacts = [filteredContacts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ContactViewModel  *vm, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString *phoneNumber = [vm.phoneNumber phoneNumberWithoutFirstDigit];
        return [self.addressBookNumbers.allKeys containsObject:phoneNumber];
    }]];
    self.addressBookViewModels = filteredContacts;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.searchController.isActive && self.searchController.searchBar.selectedScopeButtonIndex == 1) {
            self.searchResults = [self.addressBookViewModels copy];
            [self.tableView reloadData];
        }
    });
    return filteredContacts;
}

#pragma mark - Empty Data Set
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *title = @"";
    if (self.searchController.isActive) {
        BOOL contactsPermissionGranted = _contactsAuthorizationStatus == CNAuthorizationStatusAuthorized;
        switch (self.searchController.searchBar.selectedScopeButtonIndex) {
            case 0:
                title = @"No users found";
                break;
                
            case 1:
                title = contactsPermissionGranted ? @"No contacts found" : @"No permission granted";
                break;
        }
    } else if (!_isLoadingUsers) {
        title = @"No users yet";
    }
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

@end











