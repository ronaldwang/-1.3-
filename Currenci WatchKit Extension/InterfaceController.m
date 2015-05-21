//
//  InterfaceController.m
//  Currenci WatchKit Extension
//
//  Created by Aries on 15/3/23.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchKit/WKInterfaceObject.h>
#import "Util.h"
#import "CurrencyRowController.h"
#import "KeyBoardInterfaceController.h"

@interface InterfaceController()<KeyBoardInterfaceDelegate>
@property (weak, nonatomic) IBOutlet WKInterfaceTable *interFaceTable;

@property (nonatomic,retain) NSMutableArray  *currencyArray;
@property (nonatomic,retain) NSMutableDictionary  *valueDic;
@property (nonatomic,retain)  NSArray  *valueArray;
@property(nonatomic,assign)  NSInteger  currentIndex;
@property (nonatomic,assign)  BOOL  isUserInput;
@property (nonatomic,copy) NSString *inputValue;

@end

@implementation InterfaceController


- (void)keyBoardUserInput:(NSString *)input{
    self.isUserInput = YES;
    self.inputValue = input;
}

- (void)menuAction {
    [self  loadTableViewWith:[self.valueArray objectAtIndex:0]];
}

- (void)menuAction2 {
     [self  loadTableViewWith:[self.valueArray objectAtIndex:1]];
}

- (void)menuAction3 {
    [self  loadTableViewWith:[self.valueArray objectAtIndex:2]];
}

- (void)menuAction4{
     [self  loadTableViewWith:[self.valueArray objectAtIndex:3]];
}

- (void)textInputAction {
    [self presentTextInputControllerWithSuggestions:@[[self.valueArray objectAtIndex:3], [self.valueArray objectAtIndex:4], [self.valueArray objectAtIndex:5]] allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
        if (results[0] != nil) {
        [WKInterfaceController openParentApplication:@{@"infor" : results[0]} reply:^(NSDictionary *replyInfo, NSError *error) {
               [self  loadTableViewWith:results[0]];
            }];
        }
    }];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.currentIndex = [[Util  takeCurrentIndex]  intValue];
    self.inputValue = [NSString stringWithFormat:@""];
}

- (void)loadTableRows {
    
    [self.interFaceTable setNumberOfRows:self.currencyArray.count withRowType:@"CurrencyRowIdentifier"];
    
    [self.currencyArray enumerateObjectsUsingBlock:^(NSString  *string, NSUInteger idx, BOOL *stop) {
        
//        [self.interFaceTable  removeRowsAtIndexes:[NSIndexSet  indexSetWithIndex:idx]];
//        [self.interFaceTable  insertRowsAtIndexes:[NSIndexSet  indexSetWithIndex:idx] withRowType:@"CurrencyRowIdentifier"];
        
         CurrencyRowController *elementRow = [self.interFaceTable rowControllerAtIndex:idx];
        [elementRow.currencyName  setText:string];
        [elementRow.currcncyImage setImageNamed:[NSString  stringWithFormat:@"%@.png",string]];
        [elementRow.currencyValue  setText:[self.valueDic  objectForKey:string]];
        
        NSLog(@"index is %d   string is %@",(int)idx,[self.valueDic  objectForKey:string]);

    }];
}

- (void)takeValueDic:(NSString*)valueString{

    NSMutableDictionary  *dic = [NSMutableDictionary  dictionary];
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *currencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    NSString *localeRate = [[Util readDataFromNSUserDefaults]  objectForKey:currencyCode];
    NSArray  *rateArray = [Util  readSeclectCountry];
    for (int i = 0; i < rateArray.count; i++) {
        NSString  *currencyString = [rateArray  objectAtIndex:i];
            if ([currencyCode  isEqualToString:currencyString]) {
                [dic  setValue:valueString forKey:currencyString];;
            }else{
                NSString   *currcncyRate = [[Util readDataFromNSUserDefaults]  objectForKey:currencyString];
                int   dataType  = [Util readDataType];
                float  resultFloat = [Util  numberFormatterForFloat:valueString]/[localeRate doubleValue]*[currcncyRate  doubleValue];
                NSString  *result = [Util  roundUp:resultFloat afterPoint:dataType];
                [dic  setValue: [Util   numberFormatterSetting:result withFractionDigits:dataType withInput:NO]  forKey:currencyString];
            }
        }
    self.valueDic = dic;
}

- (void)loadTableViewWith:(NSString*)value{
    self.isUserInput = NO;
    self.inputValue = @"";
    [Util  saveUserInput:@"0"];
    [Util saveDefaultVauleByNsuer:[Util  numberFormatterSetting:value withFractionDigits:2 withInput:YES]];
     [self  communicatingWithCurrenci];
}

// add  Menu  on  Run-time
- (void)addMenuItems{
    self.valueArray = [Util  takeObligateValuesList];
    if (self.valueArray.count == 0) {
        self.valueArray = [NSArray  arrayWithObjects:@"10",@"20",@"50",@"100",@"500",@"1000", nil];
    }
    [self   clearAllMenuItems];
    
    CGRect bounds = [[WKInterfaceDevice currentDevice] screenBounds];
    if (CGRectEqualToRect(bounds, CGRectMake(0, 0, 156, 195))) {
        [self addMenuItemWithImageNamed:[NSString stringWithFormat:@"%d-42.png",1] title:[self.valueArray  objectAtIndex:0] action:@selector(menuAction)];
        [self addMenuItemWithImageNamed:[NSString stringWithFormat:@"%d-42.png",2] title:[self.valueArray  objectAtIndex:1] action:@selector(menuAction2)];
        [self addMenuItemWithImageNamed:[NSString stringWithFormat:@"%d-42.png",3] title:[self.valueArray  objectAtIndex:2] action:@selector(menuAction3)];
        [self addMenuItemWithImageNamed:[NSString stringWithFormat:@"%d-42.png",4] title:[self.valueArray  objectAtIndex:3] action:@selector(menuAction4)];
    }else{
       
        [self addMenuItemWithImageNamed:[NSString stringWithFormat:@"%d-38.png",1] title:[self.valueArray  objectAtIndex:0] action:@selector(menuAction)];
        [self addMenuItemWithImageNamed:[NSString stringWithFormat:@"%d-38.png",2] title:[self.valueArray  objectAtIndex:1] action:@selector(menuAction2)];
        [self addMenuItemWithImageNamed:[NSString stringWithFormat:@"%d-38.png",3] title:[self.valueArray  objectAtIndex:2] action:@selector(menuAction3)];
        [self addMenuItemWithImageNamed:[NSString stringWithFormat:@"%d-38.png",4] title:[self.valueArray  objectAtIndex:3] action:@selector(menuAction4)];
    }
}

- (void)communicatingWithCurrenci{
    
    [self  aboutCurrency];
    
    NSDictionary *applicationData = @{@"infor":@"request"};
    [WKInterfaceController openParentApplication:applicationData reply:^(NSDictionary *replyInfo, NSError *error) {
        [self  aboutCurrency];
    }];
}

- (void)aboutCurrency{
   
    self.currencyArray = [Util  readSeclectCountry];
    if (self.currencyArray.count == 0) {
        self.currencyArray = [NSMutableArray  arrayWithObjects:@"USD",@"EUR",nil];
    }
    [self  addMenuItems];
    [self  takeValueDic:[Util  readDefaultValue]];
    [self  loadTableRows];
}



- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    
    self.currentIndex = rowIndex;
    //  通过Context 传递 数据
    KeyBoardInterfaceControllerContext   *keyBoardContext = [KeyBoardInterfaceControllerContext  new];
    keyBoardContext.delegate = self;
    keyBoardContext.currentCurrency = [self.currencyArray  objectAtIndex:rowIndex];
    [self pushControllerWithName:@"keyBoardIdentifier" context:keyBoardContext];

}

- (void)dealWithUserInput:(NSString*)input{
    
    NSMutableDictionary  *dic = [NSMutableDictionary  dictionary];
    NSString *localeRate = [[Util readDataFromNSUserDefaults]  objectForKey:[self.currencyArray  objectAtIndex:self.currentIndex]];
    NSArray  *rateArray = [Util  readSeclectCountry];
    for (int i = 0; i < rateArray.count; i++) {
        NSString  *currencyString = [rateArray  objectAtIndex:i];
        if ( i == self.currentIndex) {
            [dic  setValue:input forKey:currencyString];;
        }else{
            NSString   *currcncyRate = [[Util readDataFromNSUserDefaults]  objectForKey:currencyString];
            int   dataType  = [Util readDataType];
            float  resultFloat = [Util  numberFormatterForFloat:input]/[localeRate doubleValue]*[currcncyRate  doubleValue];
            NSString  *result = [Util  roundUp:resultFloat afterPoint:dataType];
            [dic  setValue: [Util   numberFormatterSetting:result withFractionDigits:dataType withInput:NO]  forKey:currencyString];
        }
    }

    self.valueDic = dic;
    [self aboutUserInput];

    NSDictionary *applicationData = @{@"infor":@"requestInput"};
    [WKInterfaceController openParentApplication:applicationData reply:^(NSDictionary *replyInfo, NSError *error) {
        [self aboutUserInput];
    }];
    self.isUserInput = NO;
}


- (void)aboutUserInput{
 
    self.currencyArray = [Util  readSeclectCountry];
    if (self.currencyArray.count == 0) {
        self.currencyArray = [NSMutableArray  arrayWithObjects:@"USD",@"EUR",nil];
    }
    [self  loadTableRows];
}




- (void)loadDataAfterUser{
   
     dispatch_async(dispatch_get_main_queue(), ^{
         
         
         for (NSInteger  idx = 0; idx< self.interFaceTable.numberOfRows; idx++) {
             
             NSString  *string = [self.currencyArray  objectAtIndex:idx];
             
             CurrencyRowController *elementRow = [self.interFaceTable rowControllerAtIndex:idx];
             
             [elementRow.currencyName  setText:string];
             [elementRow.currcncyImage setImageNamed:[NSString  stringWithFormat:@"%@.png",string]];
             [elementRow.currencyValue  setText:[self.valueDic  objectForKey:string]];
             
              NSLog(@"index is %d     string is %@",(int)idx,[self.valueDic  objectForKey:string]);
         }
     });
}

- (void)willActivate {
    [super willActivate];
    if (!self.isUserInput) {
        if ([self.inputValue isEqualToString:@""]) {
            [self  communicatingWithCurrenci];
        }
    }else{
        [self dealWithUserInput:self.inputValue];
    }
}


- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    
}

@end
