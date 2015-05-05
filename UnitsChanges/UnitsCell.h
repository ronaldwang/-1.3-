//
//  UnitsCell.h
//  UnitsChanges
//
//  Created by zhangmeng on 14/10/24.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
@interface UnitsCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *nameAbb;
@property (weak, nonatomic) IBOutlet UIImageView *countryFlag;
@property (weak, nonatomic) IBOutlet UIImageView *dingWeiImage;

@end
