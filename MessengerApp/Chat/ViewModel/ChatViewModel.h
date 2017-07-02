//
//  ChatViewModel.h
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"
#import "AvatarView.h"

@class ChatData;

@interface ChatViewModel : NSObject

@property (readonly) JSQMessagesBubbleImage *outgoingBubbleImage;
@property (readonly) JSQMessagesBubbleImage *incomingBubbleImage;

@property (readonly, copy) NSArray <JSQMessage *> *messages;
@property (readonly, copy) NSArray *messageIDs;

- (instancetype)initWithModel:(ChatData *)model;


@end
