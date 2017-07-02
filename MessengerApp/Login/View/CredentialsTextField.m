//
//  CredentialsTextField.m
//  MessengerApp
//
//  Created by Vlad on 09.06.17.
//  Copyright © 2017 Bark. All rights reserved.
//

#import "CredentialsTextField.h"

@interface CredentialsTextField ()

@property (nonatomic, strong) UIView *tmp;

@end


@implementation CredentialsTextField


- (void)awakeFromNib {
    [super awakeFromNib];
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]}];
}

#pragma mark - Public

- (void)highlightWithRedBorder {
    [UIView animateWithDuration:0.15 animations:^{
        self.tmp.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.tmp.alpha = 0;
        }];
    }];
}

- (UIView *)tmp {
    if (!_tmp) {
        _tmp = [[UIView alloc] initWithFrame:self.frame];
        _tmp.layer.borderWidth = 2.0;
        _tmp.layer.borderColor = [UIColor colorWithRed:1.0 green:0.1 blue:0.3 alpha:1].CGColor;
        _tmp.layer.cornerRadius = 5.0;
        _tmp.alpha = 0;
        [[self superview] addSubview:_tmp];
    }
    return _tmp;
}

- (UIColor *)backgroundColor {
    return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
}



#pragma mark - Insets

//placeholder
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

//text
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}


@end
