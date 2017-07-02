//
//  AvatarView.h
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvatarView : UIView

@property (readonly) UIImageView *imageView;
@property (readonly) UILabel *initialsLabel;

- (void)setImageViewType;
- (void)setInitialsLabelType;

@end
