//
//  SnapshotParser.h
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FIRDataSnapshot;

@protocol SnapshotParser <NSObject>

- (instancetype)initWithSnapshot:(FIRDataSnapshot *)snapshot exception:(NSArray <NSString *> *)exceptions;

@end
