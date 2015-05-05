//
//  CountryViewController.h
//  UnitsChanges
//
//  Created by zhangmeng on 14/11/6.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryViewControllerDelegate <NSObject>

- (void)selectedCountry:(id)sender;

@end

@interface CountryViewController : UIViewController
@property (nonatomic,retain)  id<CountryViewControllerDelegate>delegate;
@property (nonatomic,retain) NSMutableArray *allCountry;  //  所有国家

@property (nonatomic,retain)  NSMutableArray  *selestedCountry;
@end
