//
//  GlanceController.m
//  Currenci WatchKit Extension
//
//  Created by Aries on 15/4/16.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "GlanceController.h"
#import "Util.h"

@interface GlanceController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *topLable;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *bottomLable;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *sayingLable;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *nameLable;

@end

@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSArray  *currencyArray = [Util  readSeclectCountry];
    NSString  *topCurrency = nil;
    NSString  *bottomCurrency = nil;
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *currencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    
    if (currencyArray.count>=2) {
        topCurrency = [currencyArray   objectAtIndex:0];
        bottomCurrency = [currencyArray  objectAtIndex:1];
    }else if (currencyArray.count == 1){
         topCurrency = [currencyArray   objectAtIndex:0];
        if (![topCurrency  isEqualToString:@"USD"]) {
            bottomCurrency = @"USD";
        }else{
            if ([currencyCode  isEqualToString:@"USD"]) {
                bottomCurrency = @"CNY";
            }else{
                bottomCurrency = currencyCode;
            }
        }
    }else{
        if ([currencyCode  isEqualToString:@"USD"]) {
            topCurrency = currencyCode;
            bottomCurrency = @"CNY";
        }else{
            topCurrency = currencyCode;
            bottomCurrency = @"USD";
        }
    }
    CGFloat  topRate = [[[Util  readDataFromNSUserDefaults]  objectForKey:topCurrency]  floatValue];
    CGFloat  bottomRate = [[[Util  readDataFromNSUserDefaults]  objectForKey:bottomCurrency]  floatValue];
    
    int  dataType = [Util  readDataType];
    float  resultFloat = 1/topRate*bottomRate;
    NSString * result = [Util  roundUp:resultFloat afterPoint:dataType];
    [self.topLable  setText:[NSString stringWithFormat:@"%@    %d",topCurrency,1]];
    [self.bottomLable  setText:[NSString stringWithFormat:@"%@    %@",bottomCurrency,result]];
   
    [self takeSayingLableContet];
}

- (void)willActivate {
    [super willActivate];
}

#pragma mark    从plist获取 名言

- (void)takeSayingLableContet{
    NSArray  *sayingArray = [Util  takeSayingContent];
    int   sayIndex = arc4random() % sayingArray.count;
    NSDictionary  *sayingDic = [sayingArray  objectAtIndex:sayIndex];
    NSString  *sayingContent = [sayingDic  objectForKey:@"sayingContent"];
    NSString  *name = [sayingDic   objectForKey:@"name"];
    self.sayingLable.text = sayingContent;
    self.nameLable.text = [NSString stringWithFormat:@"~%@",name];
}


- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



