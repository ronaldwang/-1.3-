//
//  BaseValueView.m
//  Currency_PAD
//
//  Created by Aries on 15/4/23.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import "BaseValueView.h"
#import "Util.h"

@implementation BaseValueView

- (id)initWithFrame:(CGRect)frame{
    self = [super  initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor  clearColor];
        
        self.currencyFlag = [[UIImageView alloc ] initWithFrame:CGRectMake(15, 25, 24, 24)];
        [self addSubview:self.currencyFlag];
        
        self.currencyName = [[UILabel alloc ] initWithFrame:CGRectMake(self.currencyFlag.frame.origin.x + self.currencyFlag.frame.size.width + 2, self.currencyFlag.frame.origin.y, 75, 25)];
        self.currencyName.textColor =  [Util  colorWithHexString:@"#aaaaaa"];
        self.currencyName.font = [UIFont  fontWithName:@"HelveticaNeue" size:20.0];
        self.currencyName.textAlignment = NSTextAlignmentRight;
        
        [self addSubview:self.currencyName];
        
        self.baseValue = [[UILabel alloc ] initWithFrame:CGRectMake(self.currencyFlag.frame.origin.x, self.currencyName.frame.origin.y + self.currencyName.frame.size.height + 5, 105, 25)];
        self.baseValue.textColor = [Util  colorWithHexString:@"#707070"];
        self.baseValue.font = [UIFont  fontWithName:@"HelveticaNeue" size:23.0];
        self.baseValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.baseValue];
        
        self.targetCurrencyFlag = [[UIImageView alloc ] initWithFrame:CGRectMake(self.currencyFlag.frame.origin.x, self.baseValue.frame.origin.y + self.baseValue.frame.size.height + 25, 24, 24)];
        [self addSubview:self.targetCurrencyFlag];
        
        self.targetCurrencyName = [[UILabel alloc ] initWithFrame:CGRectMake(self.targetCurrencyFlag.frame.origin.x + self.targetCurrencyFlag.frame.size.width + 2, self.targetCurrencyFlag.frame.origin.y, 75, 25)];
        self.targetCurrencyName.textColor = [Util  colorWithHexString:@"#aaaaaa"];
        self.targetCurrencyName.font = [UIFont  fontWithName:@"HelveticaNeue" size:20.0];
        self.targetCurrencyName.textAlignment = NSTextAlignmentRight;
        
        [self addSubview:self.targetCurrencyName];
        
        self.targetValue = [[UILabel alloc ] initWithFrame:CGRectMake(self.targetCurrencyFlag.frame.origin.x, self.targetCurrencyName.frame.origin.y + self.targetCurrencyName.frame.size.height + 5, 105, 25)];
        self.targetValue.textColor = [Util  colorWithHexString:@"#707070"];
        self.targetValue.font = [UIFont  fontWithName:@"HelveticaNeue" size:23.0];
        self.targetValue.textAlignment = NSTextAlignmentRight;
        self.targetValue.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:self.targetValue];

    }
    return self;
}


@end
