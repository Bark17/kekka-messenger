//
//  AvatarView.m
//  MessengerApp
//
//  Created by Vlad on 11.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "AvatarView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AvatarView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *initialsLabel;

@end

@implementation AvatarView

#pragma mark - Initialization
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

#pragma mark - Configuration
- (void)configure {
    self.layer.cornerRadius = self.bounds.size.width / 2.0;
    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0;
    CGRect frame = self.bounds;
    self.imageView = [[UIImageView alloc] initWithFrame:frame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.imageView setShowActivityIndicatorView:YES];
    self.initialsLabel = [[UILabel alloc] initWithFrame:frame];
    self.initialsLabel.textAlignment = NSTextAlignmentCenter;
    self.initialsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:27.0];
    [self addSubview:self.imageView];
    [self addSubview:self.initialsLabel];
}


#pragma mark - Implementation
- (void)setImageViewType {
    self.initialsLabel.alpha = 0.0;
    self.imageView.alpha = 1.0;
}

- (void)setInitialsLabelType {
    self.initialsLabel.alpha = 1.0;
    self.imageView.alpha = 0.0;
}


@end











