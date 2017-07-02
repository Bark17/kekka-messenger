//
//  ChatViewController.h
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>

@class ChatData;

@interface ChatViewController : JSQMessagesViewController

@property (nonatomic, strong) ChatData *chatData;

@end
