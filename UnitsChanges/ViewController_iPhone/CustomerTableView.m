//
//  CustomerTableView.m
//  Currenci
//
//  Created by Aries on 15/1/4.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//
#import "CustomerTableView.h"

@implementation CustomerTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delaysContentTouches = NO;
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:UIButton.class]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view{

    if ([view isKindOfClass:UIButton.class]) {
        return YES;
    }
    return [super  touchesShouldBegin:touches withEvent:event inContentView:view];
}

@end
