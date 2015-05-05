//
//  CustomPageViewController.h
//  Currenci
//
//  Created by Aries on 15/4/14.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPageViewController : UIPageViewController
@property (nonatomic,retain) NSArray  *viewControllersArray;
@property (nonatomic,assign)  NSInteger   pageIndex;
@property (nonatomic,assign) BOOL  isPageToBounce;

@end
