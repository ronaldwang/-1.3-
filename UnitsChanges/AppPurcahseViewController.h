//
//  AppPurcahseViewController.h
//  Currenci
//
//  Created by Aries on 15/3/4.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASBanker.h"
@interface AppPurcahseViewController : UIViewController
@property (nonatomic,retain) ASBanker  *banker;
@property (strong,nonatomic) NSMutableArray  *products;
@end
