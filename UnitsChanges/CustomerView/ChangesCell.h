//
//  ChangesCell.h
//  UnitsChanges
//
//  Created by zhangmeng on 14/10/24.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MGSwipeTableCell.h"

@interface ChangesCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UILabel *unitNameLable;
@property (weak, nonatomic) IBOutlet UILabel *unitValueLable;

@property (weak, nonatomic) IBOutlet UIImageView *countryFlag;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *dingWeiImage;
@property (weak, nonatomic) IBOutlet UILabel *currencyName;



@end
