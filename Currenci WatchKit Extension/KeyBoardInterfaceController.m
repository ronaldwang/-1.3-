//
//  KeyBoardInterfaceController.m
//  Currenci
//
//  Created by Aries on 15/4/30.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "KeyBoardInterfaceController.h"
#import "Util.h"


@implementation KeyBoardInterfaceControllerContext
@end


@interface KeyBoardInterfaceController ()
{
    NSMutableString *display;
}


@property (weak, nonatomic) IBOutlet WKInterfaceLabel *resultLable;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *currencyFlag;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *InputGroup;

@end




@implementation KeyBoardInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
     NSAssert([context isKindOfClass:[KeyBoardInterfaceControllerContext class]], @"Context object is not of the right kind");
    
    KeyBoardInterfaceControllerContext  *keyBoardContext = (KeyBoardInterfaceControllerContext*)context;
    self.delegate = keyBoardContext.delegate;

    [self  calculator_init];
    
}


-(void) calculator_init{

    display = [[NSMutableString alloc] initWithCapacity:40];
    [self.resultLable  setTextColor:[Util  shareInstance].themeColor];
   }


-(void) inputNum:(NSString *)str
{
        if([str isEqual:@"0"]||[str isEqual:@"1"]||[str isEqual:@"2"]||[str isEqual:@"3"]||[str isEqual:@"4"]||[str isEqual:@"5"]||[str isEqual:@"6"]||[str isEqual:@"7"]||[str isEqual:@"8"]||[str isEqual:@"9"]||[str isEqual:@"."]){
                    NSArray  *array = [display  componentsSeparatedByString:@"."];
                    if (array.count == 1) {
                        NSMutableString  *newDisplay = [NSMutableString  stringWithString:[array  objectAtIndex:0] ];
                        if ([newDisplay  intValue] != 0) {
                            [newDisplay  appendString:str];
                        }else{
                            newDisplay =[NSMutableString stringWithString:str];
                        }
                        display = newDisplay;
                    }else if (array.count == 2){
                        NSMutableString  *newDisplay = [NSMutableString  stringWithString:[array  objectAtIndex:0] ];
                        
                        if ([newDisplay  intValue] != 0) {
                            [newDisplay  appendString:str];
                        }else{
                            newDisplay =[NSMutableString stringWithString:str];
                        }
                        if (![str  isEqual:@"."]) {
                            [newDisplay appendString:@"."];
                        }
                        [newDisplay appendString:[array objectAtIndex:1]];
                        display = newDisplay;
                    }
        }
}

-(void)brain:(NSString *)str
{
    NSLocale  *locale = [NSLocale  currentLocale];
    if ([str  isEqualToString:[locale  objectForKey:NSLocaleDecimalSeparator]]) {
        str = @".";
    }
    [self inputNum:str];
    
    NSString  *localeString = [Util  numberFormatterSetting:[NSString  stringWithFormat:@"%f",[Util numberFormatterForFloat:display]] withFractionDigits:2 withInput:YES];
    
    [self.resultLable  setText:localeString];
   
}


- (IBAction)clickButton_7 {
    
    [self  brain:@"7"];
}


- (IBAction)clickButton_8 {
    [self  brain:@"8"];
}

- (IBAction)clickButton_9 {
    
     [self  brain:@"9"];
    
}

- (IBAction)clickButton_4 {
     [self  brain:@"4"];
}

- (IBAction)clickButton_5 {
     [self  brain:@"5"];
}

- (IBAction)clickButton_6 {
     [self  brain:@"6"];
}

- (IBAction)clickButton_1 {
     [self  brain:@"1"];
}

- (IBAction)clickButton_2 {
     [self  brain:@"2"];
}

- (IBAction)clickButton_3 {
     [self  brain:@"3"];
}


- (IBAction)clickButton_0 {
     [self  brain:@"0"];
}

- (IBAction)clickButton_C {
    
    display = [NSMutableString stringWithCapacity:40];
    [self.resultLable  setText:@"0"];
    
}



- (IBAction)clickButton_OK {

    if ([display  intValue] != 0) {
        NSString  *localeString = [Util  numberFormatterSetting:[NSString  stringWithFormat:@"%f",[Util numberFormatterForFloat:display]] withFractionDigits:2 withInput:YES];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(keyBoardUserInput:)]) {
            [self.delegate  keyBoardUserInput:localeString];
        }
    }
     [self  popController];
}


- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [self  setTitle:[Util  takeCurrentCurrency]];
    [self.currencyFlag  setImageNamed:[NSString  stringWithFormat:@"%@.png",[Util takeCurrentCurrency]]];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



