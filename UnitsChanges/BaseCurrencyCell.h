//
//  BaseCurrencyCell.h
//  Currenci
//
//  Created by Aries on 15/4/1.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCurrencyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *countryFlag;
@property (weak, nonatomic) IBOutlet UILabel *baseValueLable;
@property (weak, nonatomic) IBOutlet UILabel *currencyNameLable;
@property (weak, nonatomic) IBOutlet UILabel *targetCurrencyName;

@property (weak, nonatomic) IBOutlet UILabel *targetValueLable;

@property (weak, nonatomic) IBOutlet UIView *stateFlage;


@end
