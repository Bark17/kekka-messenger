//
//  ChatViewController.m
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatViewModel.h"
#import "ChatData.h"
#import "Message.h"
#import "User.h"
#import "MessagesRemoteService.h"
#import "AuthSession.h"
#import "Conversation.h"
#import "JSQMessages.h"
#import "MBProgressHUD.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "ContactViewModel.h"
#import "AvatarView.h"
#import <SDWebImage/UIButton+WebCache.h>
@import Firebase;

@interface ChatViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

#pragma mark - Properties
@property (nonatomic, strong) MessagesRemoteService *messagesService;
@property (nonatomic, strong) ChatViewModel *viewModel;
@property (nonatomic, strong) FIRDatabaseReference *messagesRef;

@property (nonatomic, assign) BOOL isLoadingMessages;
@property (nonatomic, assign) BOOL isMessagesLoaded;

@end

@implementation ChatViewController

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configure];
    [self fetchMessages];
    [self setUpDelegates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.messagesService removeAllObservers];
    [self.messagesRef removeAllObservers];
}

#pragma mark - Lazy instantiation
- (MessagesRemoteService *)messagesService {
    if (!_messagesService) {
        _messagesService = [[MessagesRemoteService alloc] initWithConversation:self.chatData.conversation andAuthSession:AuthSession.currentSession];
    }
    return _messagesService;
}


#pragma mark - Configuration
- (void)configure {
    [self.navigationController setNavigationBarHidden:NO];
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    [self configureNavigationBar];
}

- (void)configureNavigationBar {
    self.title = self.chatData.userViewModel.name;
    /* Avatar button */
    UIButton *barButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    [barButton sd_setImageWithURL:self.chatData.userViewModel.avatarURL forState:UIControlStateNormal];
    barButton.layer.cornerRadius = barButton.bounds.size.width / 2.0;
    barButton.clipsToBounds = YES;
    NSLayoutConstraint *widthConstraint = [barButton.widthAnchor constraintEqualToConstant:30];
    NSLayoutConstraint *heightConstraint = [barButton.heightAnchor constraintEqualToConstant:30];
    [widthConstraint setActive:YES];
    [heightConstraint setActive:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barButton];
}

- (void)setUpDelegates {
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
}

#pragma mark - 
- (void)fetchMessages {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.isLoadingMessages = YES;
    __weak ChatViewController *weakSelf = self;
    [self.messagesService obtainMessagesWithLimit:100
                                           offset:nil
       andCompletionBlock:^(NSArray<Message *> *messages, NSError *error) {
           weakSelf.isLoadingMessages = NO;
           if (error) {
               // TODO: Handle Error
               NSLog(@"Error fetching messages");
           } else if (messages) {
               weakSelf.chatData.messages = [messages mutableCopy];
               weakSelf.collectionView.alpha = 0;
               [weakSelf prepareViewModel];
               [weakSelf.collectionView reloadData];
           }
           weakSelf.isMessagesLoaded = YES;
           [weakSelf setUpNewMessagesObserving];
           [weakSelf scrollToBottomAnimated:NO];
           [MBProgressHUD hideHUDForView:self.view animated:YES];
           [UIView animateWithDuration:0.15 animations:^{
               weakSelf.collectionView.alpha = 1;
           }];
       }];
}

- (void)prepareViewModel {
    if (self.chatData) {
        self.viewModel = [[ChatViewModel alloc] initWithModel:self.chatData];
    }
}

#pragma mark - Observing messages
- (void)setUpNewMessagesObserving {
    if (!self.chatData) {
        return;
    }
    FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
    NSString *messagesPath = [NSString stringWithFormat:@"messages/%@", self.chatData.conversation.cid];
    self.messagesRef = [rootRef child:messagesPath];
    
    __weak ChatViewController *weakSelf = self;
    [self.messagesRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSUInteger snapshotTime = ((NSNumber *)[snapshot childSnapshotForPath:@"timestamp"].value).unsignedIntegerValue;
        NSUInteger lastMessageTime = ((NSNumber *)weakSelf.chatData.messages.lastObject.timestamp).unsignedIntegerValue;
        if (snapshotTime > lastMessageTime && weakSelf.isMessagesLoaded) {
            NSLog(@"NEW MESSAGE: %@", snapshot);
            [weakSelf handleNewMessageWithSnapshot:snapshot];
        }
    }];
}

- (void)handleNewMessageWithSnapshot:(FIRDataSnapshot *)snapshot {
    Message *new = [[Message alloc] initWithSnapshot:snapshot exception:nil];
    if (!new.userID) {
        return;
    }
    NSString *userPath = [NSString stringWithFormat:@"users/%@", new.userID];
    FIRDatabaseReference *userRef = [[[FIRDatabase database] reference] child:userPath];
    __weak ChatViewController *weakSelf = self;
    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        User *user = [[User alloc] initWithSnapshot:snapshot exception:nil];
        new.user = user;
        if (weakSelf.chatData.messages) {
            [weakSelf.chatData.messages addObject:new];
        } else {
            weakSelf.chatData.messages = [@[new] mutableCopy];
            [weakSelf prepareViewModel];
        }
        [weakSelf finishReceivingMessageAnimated:YES];
    }];
}


#pragma mark - JSQMessagesViewController method overrides
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    Message *msgToSend = [self prepareMessageWithText:text];
    NSLog(@"Sending: %@", msgToSend);
    [self.messagesService sendMessage:msgToSend withCompletionBlock:^(BOOL sent) {
        if (sent) {
            NSLog(@"Message sent successfully");
        } else {
            NSLog(@"Message wasn't sent");
        }
    }];
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - Message
- (Message *)prepareMessageWithText:(NSString *)text {
    Message *m = [Message new];
    m.userID = AuthSession.currentSession.user.uid;
    m.text = text;
    return m;
}

#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return AuthSession.currentSession.user.uid;
}

- (NSString *)senderDisplayName {
    return @"Me";
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewModel.messages.count > indexPath.item) {
        return [self.viewModel.messages objectAtIndex:indexPath.item];
    }
    return nil;
}


- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.viewModel.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.viewModel.outgoingBubbleImage;
    }
    
    return self.viewModel.incomingBubbleImage;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.viewModel.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.viewModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *currentMessage = [self.viewModel.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.viewModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    JSQMessage *msg = [self.viewModel.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        cell.textView.textColor = [UIColor whiteColor];
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}



- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}


#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"Нет сообщений с данным пользователем.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (self.isLoadingMessages) {
        return NO;
    }
    return YES;
}

@end
