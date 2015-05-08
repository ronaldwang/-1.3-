//
//  WatchSettingCell.h
//  Currenci
//
//  Created by Aries on 15/3/26.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerUITextField.h"
@interface WatchSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet CustomerUITextField *inPutTextField;
@property (weak, nonatomic) IBOutlet UIImageView *settingImage;

@end
