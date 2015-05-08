//
//  AppPurchaseCell.h
//  Currenci
//
//  Created by Aries on 15/3/13.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppPurchaseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *appPurchaseLogo;

@property (weak, nonatomic) IBOutlet UILabel *productNameLable;
@property (weak, nonatomic) IBOutlet UILabel *priceLable;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLable;

@end
