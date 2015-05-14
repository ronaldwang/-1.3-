//
//  SplitDetailViweController.h
//  Currency_PAD
//
//  Created by Aries on 15/4/22.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitDetailViweController : UIViewController<UIPopoverControllerDelegate, UISplitViewControllerDelegate>
- (void)calculateValueUnderBaseCurrency:(NSString*)targetCurrency AndValue:(NSString*)baseValue;
- (void)addbaseCurrencyList:(NSString*)baseCurrency  withValue:(NSString*)value;
@end
