//
//  BaseValueView.h
//  Currency_PAD
//
//  Created by Aries on 15/4/23.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseValueView : UIView
@property (nonatomic,retain) UIImageView    *currencyFlag;
@property (nonatomic,retain) UILabel  *currencyName;
@property (nonatomic,retain) UILabel  *baseValue;

@property (nonatomic,retain) UIImageView *targetCurrencyFlag;
@property (nonatomic,retain) UILabel  *targetCurrencyName;
@property (nonatomic,retain) UILabel  *targetValue;

@end
