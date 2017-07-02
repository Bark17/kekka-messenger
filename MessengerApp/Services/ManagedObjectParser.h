//
//  ManagedObjectParser.h
//  MessengerApp
//
//  Created by Vlad on 25.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessengerApp+CoreDataModel.h"

@protocol ManagedObjectParser <NSObject>

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject;

@end
