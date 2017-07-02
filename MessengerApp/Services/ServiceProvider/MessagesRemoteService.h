//
//  MessagesServiceProvider.h
//  MessengerApp
//
//  Created by Vlad on 13.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagesService.h"



@interface MessagesRemoteService : NSObject <MessagesService>

- (void)removeAllObservers;

@end
