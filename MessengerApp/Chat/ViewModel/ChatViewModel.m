//
//  ChatViewModel.m
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "ChatViewModel.h"
#import "ChatData.h"
#import "Message.h"
#import "User.h"
#import "ContactViewModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ChatViewModel ()

@property (nonatomic, strong) ChatData *model;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImage;
@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImage;

@end

@implementation ChatViewModel

#pragma mark - Initialization
- (instancetype)initWithModel:(ChatData *)model {
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

#pragma mark - Getters
- (NSArray<JSQMessage *> *)messages {
    NSArray <Message *> *msgs = self.model.messages;
    NSMutableArray <JSQMessage *> *tmp = [@[] mutableCopy];
    for (Message *msg in msgs) {
        JSQMessage *m = [self JSQMessageFromMessage:msg];
        [tmp addObject:m];
    }
    return [tmp copy];
}

- (JSQMessagesBubbleImage *)outgoingBubbleImage {
    if (!_outgoingBubbleImage) {
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessImage] capInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _outgoingBubbleImage = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    }
    return _outgoingBubbleImage;
}

- (JSQMessagesBubbleImage *)incomingBubbleImage {
    if (!_incomingBubbleImage) {
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessImage] capInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _incomingBubbleImage = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    return _incomingBubbleImage;
}

#pragma mark - 
- (JSQMessage *)JSQMessageFromMessage:(Message *)msg {
    NSString *senderID = msg.userID;
    NSString *senderName = msg.user.name;
    if (!senderName) {
        senderName = @"";
    }
    NSString *text = msg.text;
    JSQMessage *m = [[JSQMessage alloc] initWithSenderId:senderID
                                       senderDisplayName:senderName
                                                    date:[NSDate date]
                                                    text:text];
    return m;
}


@end
