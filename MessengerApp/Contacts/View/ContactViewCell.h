//
//  ContactViewCell.h
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactViewModel;

@interface ContactViewCell : UITableViewCell

- (void)configureWithViewModel:(ContactViewModel *)viewModel;

@end
