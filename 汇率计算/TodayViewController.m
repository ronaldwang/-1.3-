//
//  TodayViewController.m
//  汇率计算
//
//  Created by zhangmeng on 14/11/8.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "Util.h"

@interface TodayViewController () <NCWidgetProviding>
{
        double leftNum;
        double rightNum;
        double resultNum;
        NSString *myTotal;
        NSString *myOperator;
        NSString *lastOne;
    
        NSArray *numbers;
        NSArray *Operators;
        NSArray *Clears;
    
        BOOL isPlus;
        BOOL isMinus;
        BOOL isMultiply;
        BOOL isDivide;
        BOOL isleftNum;
        BOOL isrightNum;
        BOOL havePoint;
        BOOL isOperate;
        BOOL  isBackDelete;
        double numDisplay;
        NSMutableString *display;
    
       BOOL  topEditing;
       BOOL  bottomEditing;
       BOOL   threeEditing;
       BOOL  fourEditing;
}

@property (weak, nonatomic) IBOutlet UILabel *bottomLable;
@property (weak, nonatomic) IBOutlet UILabel *topLable;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIView *calculateView;
@property (nonatomic,assign) BOOL  isExpand;
@property (nonatomic,strong) NSMutableDictionary  *rateDic;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;

@property (weak, nonatomic) IBOutlet UIButton *appButton;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;



@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@property (weak, nonatomic) IBOutlet UILabel *currencyLable_one;
@property (weak, nonatomic) IBOutlet UILabel *currencyLable_two;

@property (weak, nonatomic) IBOutlet UILabel *currencyLable_three;
@property (weak, nonatomic) IBOutlet UILabel *currencyLable_four;
@property (weak, nonatomic) IBOutlet UILabel *valueLable_three;
@property (weak, nonatomic) IBOutlet UILabel *valueLable_four;


@property (weak, nonatomic) IBOutlet UIImageView *currecnyFlag_1;

@property (weak, nonatomic) IBOutlet UIImageView *currecnyFlag_2;

@property (weak, nonatomic) IBOutlet UIImageView *currecnyFlag_3;

@property (weak, nonatomic) IBOutlet UIImageView *currecnyFlag_4;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonVerticalConstraint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalContraintToleft;


@end

@implementation TodayViewController

- (IBAction)rateChangesAction:(id)sender {
    
    if (!self.isExpand) {
        [UIView  animateWithDuration:0.2 animations:^{
        } completion:^(BOOL finished) {
            self.viewHeightConstraint.constant = 210.0;
            self.isExpand = YES;
            self.calculateView.hidden = NO;
            self.appButton.hidden = YES;
            self.refreshButton.hidden = YES;
            self.expandButton.hidden = NO;
            self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, self.backButtonVerticalConstraint.constant + 40 + 210);
        }];
    }else{
        [UIView  animateWithDuration:0.2 animations:^{
            self.viewHeightConstraint.constant = 0.0;
            self.calculateView.hidden = YES;
            self.appButton.hidden = NO;
            self.refreshButton.hidden = NO;
            self.expandButton.hidden = YES;
            self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, self.backButtonVerticalConstraint.constant + 40);
        } completion:^(BOOL finished) {
            self.isExpand = NO;
        }];
    }
}

// 通过上下文打开 app
- (IBAction)openAppAction:(UIButton*)sender{
    NSExtensionContext  *extensionContext = [self  extensionContext];
    NSURL  *url = [NSURL  URLWithString:@"CurrencyChanger://"];
    [extensionContext  openURL:url completionHandler:^(BOOL success) {
    }];
}

// 刷新
- (IBAction)refreshAction:(UIButton *)sender {
    
    [self  runSpinAnimationOnView:sender duration:0.5 rotations:1.0 repeat:1];
   
    [self   ratesAndCountryRequest];
    
}

//   旋转
- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


#pragma mark
#pragma mark     汇率数据更新
- (void)ratesAndCountryRequest{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString  *urlString = [NSString stringWithFormat:@"%s","http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];
        NSURL  *url = [NSURL  URLWithString:urlString];
        NSURLRequest  *request = [NSURLRequest  requestWithURL:url];
        NSError  *error = nil;
        NSData  *receiveData = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:&error];
        if (receiveData != nil || error == nil) {
            NSDictionary  *dataDic = [NSJSONSerialization  JSONObjectWithData:receiveData options:NSJSONReadingMutableContainers error:&error];
            if (error== nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                   
                    [Util  saveRequestDate:[Util  changeDateToStringWith:[NSDate  date]]];
                    self.rateDic = [Util  deaWithRequestData:[dataDic  objectForKey:@"list"]];
                    [Util saveTextByNSUserDefaults:self.rateDic];
                    [Util  saveAllCountryInfor:self.rateDic];
                    
                    [self   takeForSelectCountry];

                });
            }
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rateDic = [NSMutableDictionary dictionary];
    self.rateDic = [Util readDataFromNSUserDefaults];
    self.isExpand = NO;
    self.viewHeightConstraint.constant = 0.0;
    self.calculateView.hidden = YES;
    self.expandButton.hidden = YES;
    

    BOOL  isAppPurchase = NO;
    
    NSString  *productIdPlus = @"plus";
    NSString  *productIdChart = @"chart";
    
    BOOL  is_buy = [Util  isAppPurchaseWithProductID:productIdPlus];
    BOOL  is_chart = [Util  isAppPurchaseWithProductID:productIdChart];
    
    isAppPurchase = !(is_buy || is_chart);
    
    [self  resetInterfaceByAppPurchase:isAppPurchase];
    [self calculator_init];
    [self drawInterFaceCorner];
    [self  takeForSelectCountry];

}

- (void)viewWillAppear:(BOOL)animated{
    [super  viewWillAppear:animated];
    NSLocale  *locale = [NSLocale  currentLocale];
    UIButton  *button = (UIButton*)[self.calculateView  viewWithTag:2024];
    [button  setTitle:[locale  objectForKey:NSLocaleDecimalSeparator] forState:UIControlStateNormal];
}

- (void)resetInterfaceByAppPurchase:(BOOL)isAppPurchase{
    
    self.currencyLable_four.hidden = isAppPurchase;
    self.valueLable_four.hidden = isAppPurchase;
    self.currecnyFlag_4.hidden = isAppPurchase;
    
    self.currencyLable_three.hidden = isAppPurchase;
    self.valueLable_three.hidden = isAppPurchase;
    self.currecnyFlag_3.hidden = isAppPurchase;
    
    
    UIButton  *button = (UIButton*)[self.view  viewWithTag:20150303];
    button.hidden = isAppPurchase;
    
    button = (UIButton*)[self.view  viewWithTag:20150304];
    button.hidden = isAppPurchase;
    
    UIImageView  *imageView = (UIImageView*)[self.view  viewWithTag:20150305];
    imageView.hidden = isAppPurchase;
    
    imageView = (UIImageView*)[self.view  viewWithTag:20150306];
    imageView.hidden = isAppPurchase;

    if (isAppPurchase) {
        self.backButtonVerticalConstraint.constant =  110;
    }else{
        self.backButtonVerticalConstraint.constant =  190;
    }
    
    self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, self.backButtonVerticalConstraint.constant + 40);
}


//   收藏国家
- (NSMutableArray*)readCollectCountry{

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    NSMutableArray *collectCountry = [shared valueForKey:@"collectCountry"];
    return collectCountry;

}


- (void)drawInterFaceCorner{
    self.topLable.userInteractionEnabled = YES;
    self.bottomLable.userInteractionEnabled = YES;
}


#pragma mark
#pragma mark      编辑
- (IBAction)topButtonAction:(id)sender {
    
    bottomEditing = NO;
    topEditing = YES;
    threeEditing = NO;
    fourEditing = NO;
    
    [Util  saveWidgetState:@"topEditing"];
    
    NSString  *colorString = [Util  readColorString];
    if (colorString == nil ) {
        self.topLable.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        self.currencyLable_one.textColor = [UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
    }else{
        self.topLable.textColor = [Util  colorWithHexString:[Util  readColorString]];
        self.currencyLable_one.textColor =  [Util  colorWithHexString:[Util  readColorString]];
    }
    
    self.currencyLable_two.textColor = [UIColor whiteColor];
    self.bottomLable.textColor = [UIColor whiteColor];
    self.currencyLable_three.textColor = [UIColor  whiteColor];
    self.valueLable_three.textColor = [UIColor  whiteColor];
    self.currencyLable_four.textColor = [UIColor whiteColor];
    self.valueLable_four.textColor = [UIColor whiteColor];
    [self  resetLable];

}


- (IBAction)bottomButtonAction:(id)sender {
    
    bottomEditing = YES;
    topEditing = NO;
    threeEditing = NO;
    fourEditing = NO;
    
    [Util  saveWidgetState:@"bottomEditing"];
    
    NSString  *colorString = [Util  readColorString];
    if (colorString == nil ) {
        self.bottomLable.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        self.currencyLable_two.textColor = [UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
    }else{
        self.bottomLable.textColor = [Util  colorWithHexString:[Util  readColorString]];
        self.currencyLable_two.textColor = [Util  colorWithHexString:[Util  readColorString]];
    }
    
    self.topLable.textColor = [UIColor whiteColor];
    self.currencyLable_one.textColor = [UIColor  whiteColor];
    
    self.currencyLable_three.textColor = [UIColor  whiteColor];
    self.valueLable_three.textColor = [UIColor  whiteColor];
    
    self.currencyLable_four.textColor = [UIColor whiteColor];
    self.valueLable_four.textColor = [UIColor whiteColor];
    
    [self  resetLable];

}

- (IBAction)threeButtonAction:(UIButton *)sender {
    
    bottomEditing = NO;
    topEditing = NO;
    threeEditing = YES;
    fourEditing = NO;
    
    [Util  saveWidgetState:@"threeEditing"];
    
    NSString  *colorString = [Util  readColorString];
    if (colorString == nil ) {
        self.currencyLable_three.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        self.valueLable_three.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        
    }else{
        self.currencyLable_three.textColor = [Util  colorWithHexString:[Util  readColorString]];
       self.valueLable_three.textColor = [Util  colorWithHexString:[Util  readColorString]];
    }
    
    self.topLable.textColor = [UIColor whiteColor];
    self.currencyLable_one.textColor = [UIColor  whiteColor];
    
    self.bottomLable.textColor = [UIColor whiteColor];
    self.currencyLable_two.textColor = [UIColor  whiteColor];
    
    self.currencyLable_four.textColor = [UIColor whiteColor];
    self.valueLable_four.textColor = [UIColor whiteColor];
    
    [self  resetLable];

}

- (IBAction)fourButtonAction:(UIButton *)sender {
    
    bottomEditing = NO;
    topEditing = NO;
    threeEditing = NO;
    fourEditing = YES;
    
    [Util  saveWidgetState:@"fourEditing"];

    NSString  *colorString = [Util  readColorString];
    if (colorString == nil ) {
        self.currencyLable_four.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        self.valueLable_four.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        
    }else{
        self.currencyLable_four.textColor = [Util  colorWithHexString:[Util  readColorString]];
        self.valueLable_four.textColor = [Util  colorWithHexString:[Util  readColorString]];
    }
    
    self.topLable.textColor = [UIColor whiteColor];
    self.currencyLable_one.textColor = [UIColor  whiteColor];
    
    self.bottomLable.textColor = [UIColor whiteColor];
    self.currencyLable_two.textColor = [UIColor  whiteColor];
    
    self.currencyLable_three.textColor = [UIColor whiteColor];
    self.valueLable_three.textColor = [UIColor whiteColor];
    
    [self  resetLable];
}


#pragma mark
#pragma mark   重置
- (void)resetLable{
    
    self.bottomLable.text = @"0";
    self.topLable.text = @"0";
    self.valueLable_four.text = @"0";
    self.valueLable_three.text = @"0";
    
    myTotal = @"";
    leftNum = 0.00;
    rightNum = 0.00;
    display = [NSMutableString  stringWithString:@""];
    numDisplay = 0.00;
    
    if (!self.isExpand) {
        [self  rateChangesAction:nil];
    }
}


#pragma mark
#pragma mark     根据已选币种布局
- (void)takeForSelectCountry{
    
    NSArray  *selcetCountry = [Util  readSeclectCountry];
    int   selectCount = (int)selcetCountry.count;
    
    BOOL  isAppPurchase = NO;
    NSString  *productIdPlus = @"plus";
    NSString  *productIdChart = @"chart";
    BOOL  is_buy = [Util  isAppPurchaseWithProductID:productIdPlus];
    BOOL  is_chart = [Util  isAppPurchaseWithProductID:productIdChart];
    isAppPurchase = (is_buy || is_chart);

    if (selectCount == 0) {
        self.currencyLable_one.text = @"USD";
        self.currencyLable_two.text = @"CNY";
    }else if(selectCount == 1){
        NSString  *first = [selcetCountry  objectAtIndex:0];
        NSString  *second = nil;
        if ([first  isEqualToString:[[NSLocale  currentLocale]   objectForKey:NSLocaleCurrencyCode]] && ![first isEqualToString:@"USD"]) {
            second = @"USD";
        }else if([first  isEqualToString:[[NSLocale  currentLocale]   objectForKey:NSLocaleCurrencyCode]] && [first isEqualToString:@"USD"]){
            second = @"EUR";
        }else{
            second = [[NSLocale  currentLocale]   objectForKey:NSLocaleCurrencyCode];
        }
        self.currencyLable_one.text = first;
        self.currencyLable_two.text = second;
    }else if (selectCount ==  2){
        self.currencyLable_one.text = [selcetCountry  objectAtIndex:0] ;
        self.currencyLable_two.text = [selcetCountry  objectAtIndex:1];
        
    }else{
        self.currencyLable_one.text = [selcetCountry  objectAtIndex:0] ;
        self.currencyLable_two.text = [selcetCountry  objectAtIndex:1];
    }
    
    if (isAppPurchase) {
        
        if (selectCount < 3) {
            [self  resetInterfaceByAppPurchase:YES];
        }
        
        if(selectCount == 3){
            self.currencyLable_one.text = [selcetCountry  objectAtIndex:0] ;
            self.currencyLable_two.text = [selcetCountry  objectAtIndex:1];
            self.currencyLable_three.text = [selcetCountry  objectAtIndex:2];
            
            self.currencyLable_four.hidden = YES;
            self.valueLable_four.hidden  = YES;
            UIButton *button = (UIButton*)[self.view  viewWithTag:20150304];
            button.hidden = YES;
            UIImageView  *imageView = (UIImageView*)[self.view  viewWithTag:20150305];
            imageView.hidden = YES;
            
//            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
//            effectView.frame = imageView.bounds;
//            [effectView.contentView  addSubview:effectView];
//            [self.view addSubview:effectView];
//            [self.view  sendSubviewToBack:effectView];
            
            self.backButtonVerticalConstraint.constant =  140;
            self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, self.backButtonVerticalConstraint.constant + 40);
        
        }else if(selectCount > 3){
            self.currencyLable_one.text = [selcetCountry  objectAtIndex:0] ;
            self.currencyLable_two.text = [selcetCountry  objectAtIndex:1];
            self.currencyLable_three.text = [selcetCountry  objectAtIndex:2];
            self.currencyLable_four.text = [selcetCountry  objectAtIndex:3];
        }
    }
    
    
    NSString  *stateString = [Util  widgetSatte];
    NSString  *result = [Util widgetResult];
    NSString  *colorString = [Util  readColorString];
    if (result == nil ||  result.doubleValue*10000/100 ==0) {
        result = [Util  readDefaultValue];
    }
    // bottom
    CGFloat rateTwo = [[self.rateDic objectForKey:self.currencyLable_two.text]  floatValue];
    // top
    CGFloat  rateOne = [[self.rateDic objectForKey:self.currencyLable_one.text]  floatValue];
    // three
    CGFloat rateThree = [[self.rateDic objectForKey:self.currencyLable_three.text]  floatValue];
    // four
    CGFloat  rateFour = [[self.rateDic objectForKey:self.currencyLable_four.text]  floatValue];

    if ([stateString  isEqualToString:@"topEditing"]) {
        
        if (colorString == nil ) {
            self.topLable.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
            self.currencyLable_one.textColor = [UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        }else{
            self.topLable.textColor = [Util  colorWithHexString:[Util  readColorString]];
            self.currencyLable_one.textColor = [Util  colorWithHexString:[Util  readColorString]];
        }

        self.topLable.text = [Util numberFormatterSetting:result withFractionDigits:4 withInput:YES];
        self.bottomLable.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.topLable.text] andRate1:rateTwo andRate2:rateOne];
        self.valueLable_three.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.topLable.text] andRate1:rateThree andRate2:rateOne];
        self.valueLable_four.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.topLable.text] andRate1:rateFour andRate2:rateOne];

    }else if ([stateString  isEqualToString:@"bottomEditing"]){
        
        if (colorString == nil ) {
            self.bottomLable.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
            self.currencyLable_two.textColor = [UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        }else{
            self.bottomLable.textColor = [Util  colorWithHexString:[Util  readColorString]];
            self.currencyLable_two.textColor = [Util  colorWithHexString:[Util  readColorString]];
        }

         self.bottomLable.text = [Util numberFormatterSetting:result withFractionDigits:4 withInput:YES];
        self.topLable.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.bottomLable.text] andRate1:rateOne andRate2:rateTwo];
        self.valueLable_three.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.bottomLable.text] andRate1:rateThree andRate2:rateTwo];
        self.valueLable_four.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.bottomLable.text] andRate1:rateFour andRate2:rateTwo];
    }else if ([stateString  isEqualToString:@"threeEditing"]){
        
        if (colorString == nil ) {
            self.currencyLable_three.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
           self.valueLable_three.textColor = [UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        }else{
            self.currencyLable_three.textColor = [Util  colorWithHexString:[Util  readColorString]];
            self.valueLable_three.textColor = [Util  colorWithHexString:[Util  readColorString]];
        }
    
        self.valueLable_three.text = [Util numberFormatterSetting:result withFractionDigits:4 withInput:YES];
        self.topLable.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.valueLable_three.text] andRate1:rateOne andRate2:rateThree];
        self.bottomLable.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.valueLable_three.text] andRate1:rateTwo andRate2:rateThree];
        self.valueLable_four.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.valueLable_three.text] andRate1:rateFour andRate2:rateThree];
    
    }else if ([stateString  isEqualToString:@"fourEditing"]){
        
        if (colorString == nil ) {
            self.currencyLable_four.textColor =[UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
            self.valueLable_four.textColor = [UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
        }else{
            self.currencyLable_four.textColor = [Util  colorWithHexString:[Util  readColorString]];
            self.valueLable_four.textColor = [Util  colorWithHexString:[Util  readColorString]];
        }

        self.valueLable_four.text = [Util numberFormatterSetting:result withFractionDigits:4 withInput:YES];
        self.topLable.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.valueLable_four.text] andRate1:rateOne andRate2:rateFour];
        self.bottomLable.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.valueLable_four.text] andRate1:rateTwo andRate2:rateFour];
        self.valueLable_three.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.valueLable_four.text] andRate1:rateThree andRate2:rateFour];
    }else{
        self.topLable.text  = [Util readDefaultValue];
        self.bottomLable.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.topLable.text] andRate1:rateTwo andRate2:rateOne];
        self.valueLable_three.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.topLable.text] andRate1:rateThree andRate2:rateOne];
        self.valueLable_four.text = [self takeCurrcncyValueBy:[Util  numberFormatterForFloat:self.topLable.text] andRate1:rateFour andRate2:rateOne];
    }
    
    
    self.currecnyFlag_1.image = [UIImage  imageNamed:[NSString  stringWithFormat:@"%@.png",self.currencyLable_one.text]];
    self.currecnyFlag_2.image = [UIImage  imageNamed:[NSString  stringWithFormat:@"%@.png",self.currencyLable_two.text]];
    self.currecnyFlag_3.image = [UIImage  imageNamed:[NSString  stringWithFormat:@"%@.png",self.currencyLable_three.text]];
     self.currecnyFlag_4.image = [UIImage  imageNamed:[NSString  stringWithFormat:@"%@.png",self.currencyLable_four.text]];
}

#pragma  mak
#pragma mark    汇率计算
- (NSString*)takeCurrcncyValueBy:(float)value andRate1:(float)rate1 andRate2:(float)rate2{
     CGFloat rateBase = [[self.rateDic objectForKey:@"USD"]  floatValue];
     NSString  *valueString = [NSString  string];
     int  dataType = [Util  readDataType];

     float  resultFloat = value*(rate1/rate2*rateBase);
     NSString  *tempString  =  [Util  roundUp:resultFloat afterPoint:dataType];
     valueString = [Util  numberFormatterSetting:tempString withFractionDigits:dataType withInput:NO];
     return valueString;
}

//   计算汇率
- (void)calculateChanges:(NSString*)result{
    
    CGFloat rateTwo = [[self.rateDic objectForKey:self.currencyLable_two.text]  floatValue];
    CGFloat  rateOne = [[self.rateDic objectForKey:self.currencyLable_one.text]  floatValue];
    CGFloat rateThree = [[self.rateDic objectForKey:self.currencyLable_three.text]  floatValue];
    CGFloat  rateFour = [[self.rateDic objectForKey:self.currencyLable_four.text]  floatValue];
    
    if (bottomEditing && (result.length <=10)) {
        self.bottomLable.text = [Util numberFormatterSetting:result withFractionDigits:4 withInput:YES];
        
        self.topLable.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateOne andRate2:rateTwo];
        self.valueLable_three.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateThree andRate2:rateTwo];
        self.valueLable_four.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateFour andRate2:rateTwo];
        
    }else if (topEditing && (result.length <=10)){
        self.topLable.text = [Util numberFormatterSetting:result withFractionDigits:4 withInput:YES];
        self.bottomLable.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateTwo andRate2:rateOne];
        self.valueLable_three.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateThree andRate2:rateOne];
        self.valueLable_four.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateFour andRate2:rateOne];
    }else if (threeEditing && (result.length <=10)){
        self.valueLable_three.text = [Util numberFormatterSetting:result withFractionDigits:4 withInput:YES];
        self.bottomLable.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateTwo andRate2:rateThree];
        self.topLable.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateOne andRate2:rateThree];
        self.valueLable_four.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateFour andRate2:rateThree];
    }else if (fourEditing && (result.length <=10)){
        
        self.valueLable_four.text = [Util numberFormatterSetting:result withFractionDigits:4 withInput:YES];
        self.bottomLable.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateTwo andRate2:rateFour];
        self.topLable.text = [self takeCurrcncyValueBy:[result  floatValue] andRate1:rateOne andRate2:rateFour];
        self.valueLable_three.text = [self takeCurrcncyValueBy:[result floatValue] andRate1:rateThree andRate2:rateFour];
    }
    
    [Util  saveWidgetResult:result];
    
}

- (void)removeCollectCountry{

    for (UIButton  *button  in self.mainView.subviews) {
        if (button.tag >= 1000 && [button  isKindOfClass:[UIButton  class]]) {
            [button  removeFromSuperview];
        }
    }
}

-(void) calculator_init{
    numbers = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".", nil];
    Operators = [[NSArray alloc] initWithObjects:@"+/−",@"%",@"÷",@"×",@"−",@"+",@"=", nil];
    Clears = [[NSArray alloc] initWithObjects:@"←",@"C",nil];
    display = [[NSMutableString alloc] initWithCapacity:40];
    resultNum = 0;
    leftNum = 0;
    rightNum = 0;
    isPlus = false;
    isMinus= false;
    isMultiply = false;
    isDivide = false;
    isleftNum = true;
    isrightNum = false;
    havePoint = false;
    isOperate = false;
    lastOne = nil;
}

-(void) calculator{
    isleftNum = true;
    if (isPlus) {
        numDisplay =leftNum +rightNum;
        int tmp = (int) numDisplay;
        if(tmp == numDisplay)
            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
        else
            myTotal = [[NSString alloc] initWithFormat:@"%f",numDisplay];
    }else if(isMinus){
        numDisplay =leftNum -rightNum;
        int tmp = (int) numDisplay;
        if(tmp == numDisplay)
            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
        else
            myTotal = [[NSString alloc] initWithFormat:@"%f",numDisplay];
    }else if(isMultiply){
        numDisplay =leftNum*rightNum;
        int tmp = (int) numDisplay;
        if(tmp == numDisplay)
            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
        else
            myTotal = [[NSString alloc] initWithFormat:@"%f",numDisplay];
        
    }else if(isDivide){
        numDisplay =leftNum/rightNum;
        int tmp = (int) numDisplay;
        if(tmp == numDisplay)
            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
        else
            myTotal = [[NSString alloc] initWithFormat:@"%f",numDisplay];
    }
    isPlus = false;
    isMinus= false;
    isMultiply = false;
    isDivide = false;
    isleftNum = true;
    isrightNum = false;
    isOperate = false;
    resultNum = numDisplay;
    leftNum = resultNum;
    [self calculateChanges:[NSString stringWithFormat:@"%f",[myTotal doubleValue]]];
    
}

-(void) inputNum:(NSString *)str
{
    if([lastOne isEqual:@"0"]||[lastOne isEqual:@"1"]||[lastOne isEqual:@"2"]||[lastOne isEqual:@"3"]||[lastOne isEqual:@"4"]||[lastOne isEqual:@"5"]||[lastOne isEqual:@"6"]||[lastOne isEqual:@"7"]||[lastOne isEqual:@"8"]||[lastOne isEqual:@"9"]||[lastOne isEqual:@"."]){
        for (int i = 0; i < [numbers count]; i++) {
            if ([str isEqual:[numbers objectAtIndex:i]]) {
                if (havePoint&&[str isEqual: @"."]) {
                    break;
                }
                NSLog(@"display is %@",display);
                
                if([str isEqual:@"."]){
                    havePoint = YES;
                }
                
                if (display.length >=11) {
                    break;
                }
                
                if (!havePoint) {
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
                }else{
                    NSArray  *array = [display  componentsSeparatedByString:@"."];
                    if (array.count ==1 ) {
                        [display  appendString:str];
                    }else{
                        NSString  *tempString = [array objectAtIndex:1];
                        if (tempString.length < 4) {
                            [display  appendString:str];
                        }
                    }

                }
                NSLog(@"display is %@",display);
                if (isleftNum) {
                    leftNum = [display doubleValue];
                    int tmp = (int) leftNum;
                    if(tmp == leftNum)
                        myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                    else
                        myTotal = [[NSString alloc] initWithFormat:@"%.4f",leftNum];
                }else{
        
                    rightNum = [display doubleValue];
                    int tmp = (int) rightNum;
                    if(tmp == rightNum)
                        myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                    else
                        myTotal = [[NSString alloc] initWithFormat:@"%.4f",rightNum];
                }
                break;
            }
        }
        NSLog(@"str is %@,++++++++++",str);
    }else{
        for (int i = 0; i < [numbers count]; i++) {
            if ([str isEqual:[numbers objectAtIndex:i]]) {
                if([str isEqual:@"."]){
                    if (isleftNum) {
                        leftNum =0;
                        int tmp = (int) leftNum;
                        if(tmp == leftNum)
                            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                        else
                            myTotal = [[NSString alloc] initWithFormat:@"%.4f",leftNum];
                    }else{
                        rightNum = 0;
                        int tmp = (int) rightNum;
                        if(tmp == rightNum)
                            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                        else
                            myTotal = [[NSString alloc] initWithFormat:@"%.4f",rightNum];
                    }
                }
                else
                {
                    if (!isBackDelete) {
                        if (isleftNum) {
                            leftNum = [str doubleValue];
                            int tmp = (int) leftNum;
                            if(tmp == leftNum)
                                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                            else
                                myTotal = [[NSString alloc] initWithFormat:@"%.4f",leftNum];
                        }else{
                            rightNum = [str doubleValue];
                            int tmp = (int) rightNum;
                            if(tmp == rightNum)
                                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                            else
                                myTotal = [[NSString alloc] initWithFormat:@"%.4f",rightNum];
                        }
                    }else{
                        
                        if (display.length >=11) {
                            break;
                        }

                        if (!havePoint) {
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
                        }else{
                            NSArray  *array = [display  componentsSeparatedByString:@"."];
                            if (array.count ==1 ) {
                                [display  appendString:str];
                            }else{
                                NSString  *tempString = [array objectAtIndex:1];
                                if (tempString.length < 4) {
                                    [display  appendString:str];
                                }
                            }

                        }
                        NSLog(@"display is %@",display);
                        if (isleftNum) {
                            leftNum = [display doubleValue];
                            int tmp = (int) leftNum;
                            if(tmp == leftNum)
                                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                            else
                                myTotal = [[NSString alloc] initWithFormat:@"%.4f",leftNum];
                        }else{
                            rightNum = [display doubleValue];
                            int tmp = (int) rightNum;
                            if(tmp == rightNum)
                                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                            else
                                myTotal = [[NSString alloc] initWithFormat:@"%.4f",rightNum];
                        }
                    }
                }
                break;
            }
        }
      
        if([str isEqual:@"0"]||[str isEqual:@"1"]||[str isEqual:@"2"]||[str isEqual:@"3"]||[str isEqual:@"4"]||[str isEqual:@"5"]||[str isEqual:@"6"]||[str isEqual:@"7"]||[str isEqual:@"8"]||[str isEqual:@"9"]||[str isEqual:@"."]){
            if (!isBackDelete) {
                
                if (display.length >=11) {
                    return;
                }

                if (!havePoint) {
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
                }else{
                    NSArray  *array = [display  componentsSeparatedByString:@"."];
                    if (array.count ==1 ) {
                        [display  appendString:str];
                    }else{
                        NSString  *tempString = [array objectAtIndex:1];
                        if (tempString.length < 4) {
                            [display  appendString:str];
                        }
                    }
                }
                
            }else {
                isBackDelete = NO;
            }
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
    
    if([str isEqual:@"+/−"]||[str isEqual:@"%"]||[str isEqual:@"÷"]||[str isEqual:@"×"]||[str isEqual:@"−"]||[str isEqual:@"+"]||[str isEqual:@"="]){
        if ([str isEqual:@"+/−"]) {
            numDisplay = -[myTotal doubleValue];
            int tmp = (int) numDisplay;
            if(tmp == numDisplay)
                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
            else
                myTotal = [[NSString alloc] initWithFormat:@"%f",numDisplay];
        }else if([str isEqual:@"%"]){
            numDisplay = [myTotal doubleValue]/100;
            int tmp = (int) numDisplay;
            if(tmp == numDisplay)
                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
            else
                myTotal = [[NSString alloc] initWithFormat:@"%f",numDisplay];
        }else if([str isEqual:@"÷"]){
            
            if(isOperate){
                leftNum = numDisplay;
                rightNum = 1;
                isDivide = YES;
                isPlus = NO;
                isMinus = NO;
                isMultiply = NO;
                [self calculator];
            }
            
            isleftNum = NO;
            display = [[NSMutableString alloc] initWithFormat:@"%@",@"0"];
            isrightNum = YES;
            isDivide = YES;
            isOperate = YES;
            havePoint = NO;
            isPlus = NO;
            isMinus = NO;
            isMultiply = NO;
            
        }
        else if([str isEqual:@"×"]){
            if(isOperate){
                leftNum = numDisplay;
                rightNum = 1;
                isMultiply = YES;
                isPlus = NO;
                isMinus = NO;
                isDivide = NO;
                [self calculator];
            }
            isleftNum = NO;
            display = [[NSMutableString alloc] initWithFormat:@"%@",@"0"];
            isrightNum = YES;
            isMultiply = YES;
            isPlus = NO;
            isMinus = NO;
            isDivide = NO;
            isOperate = YES;
            havePoint = NO;
        }
        else if([str isEqual:@"−"]){
            if(isOperate){
                leftNum = numDisplay;
                rightNum = 0;
                isMinus = YES;
                isMultiply = NO;
                isPlus = NO;
                isDivide = NO;
                [self calculator];
            }
            
            isleftNum = NO;
            display = [[NSMutableString alloc] initWithFormat:@"%@",@"0"];
            isrightNum = YES;
            isMinus = YES;
            isMultiply = NO;
            isPlus = NO;
            isDivide = NO;
            isOperate = YES;
            havePoint = NO;
            
        }else if([str isEqual:@"+"]){
            
            if(isOperate){
                leftNum = numDisplay;
                rightNum = 0;
                isPlus = YES;
                isMultiply = NO;
                isMinus = NO;
                isDivide = NO;
                [self calculator];
            }
            isleftNum = NO;
            display = [[NSMutableString alloc] initWithFormat:@"%@",@"0"];
            isrightNum = YES;
            isPlus = YES;
            isMultiply = NO;
            isMinus = NO;
            isDivide = NO;
            isOperate = YES;
            havePoint = NO;
        }
        else if([str isEqual:@"="]){
            [self calculator];
            leftNum = resultNum;
        }
    }
    
    if([str isEqual:@"←"]){
        if ([myTotal  intValue] == 0) {
            havePoint = NO;
            isOperate = NO;
            
            display = [NSMutableString  stringWithString:myTotal];
            leftNum = 0;
            rightNum = 0;
            isrightNum = NO;
            isleftNum = YES;
            isPlus = NO;
            isMultiply = NO;
            isMinus = NO;
            isDivide = NO;
            return;
        }
        display = [NSMutableString  stringWithString:myTotal];
        leftNum = 0;
        rightNum = 0;
        isleftNum = YES;
        isPlus = NO;
        isMultiply = NO;
        isMinus = NO;
        isDivide = NO;
        isBackDelete = YES;
        isOperate = NO;
        
        if (isleftNum) {
            NSString *newDisplay = [display substringToIndex:[display length]-1];
            display =[[NSMutableString alloc] initWithFormat:@"%@",newDisplay];
            leftNum = [display doubleValue];
            int tmp = (int) leftNum;
            if(tmp == leftNum)
                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
            else
                myTotal= display;
        }else{
            NSString *newDisplay = [display substringToIndex:[display length]-1];
            display =[[NSMutableString alloc] initWithFormat:@"%@",newDisplay];
            rightNum = [display doubleValue];
            int tmp = (int) rightNum;
            if(tmp == rightNum)
                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
            else
                myTotal = display;
        }
    }else if([str isEqual:@"C"]){
        [Util  saveWidgetResult:@"0"];
        [self calculator_init];
        myTotal = @"0";
        numDisplay = 0;
    }
    
    if (isOperate) {
        int   right = (int)(rightNum*100);
        if (right != 0) {
            [self calculator];
            lastOne = str;
            return;
        }
    }
    lastOne = str;

    [self   calculateChanges:myTotal];
}

- (IBAction)onClickButton:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    [self brain:button.titleLabel.text];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 
#pragma  mark  NCWidgetProviding
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    //  修改插件的上下左右缩进量
    UIEdgeInsets   edgeInsets = defaultMarginInsets;
    edgeInsets.bottom =  0.0;
    edgeInsets.top = 0.0;
    edgeInsets.right = 0.0;
    edgeInsets.left = 0.0;
    return edgeInsets;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
}




@end
