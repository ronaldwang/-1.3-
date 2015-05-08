//
//  CurrencyController.h
//  Currency_PAD
//
//  Created by Aries on 15/4/23.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryViewControllerDelegate <NSObject>

- (void)selectedCountry:(id)sender;

@end


@interface CurrencyController : UITableViewController
@property (nonatomic,retain)  id<CountryViewControllerDelegate>delegate;
@end
