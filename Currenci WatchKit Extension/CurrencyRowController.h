//
//  CurrencyRowController.h
//  Currenci
//
//  Created by Aries on 15/1/23.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchKit;
@interface CurrencyRowController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *currencyRowGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *currcncyImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *currencyName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *currencyValue;

@end
