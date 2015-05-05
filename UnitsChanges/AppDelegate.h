//
//  AppDelegate.h
//  UnitsChanges
//
//  Created by zhangmeng on 14/10/24.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPageViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL allowRotation;

@property(nonatomic,retain)  CustomPageViewController  *pageViewController;

@end

