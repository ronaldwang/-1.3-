//
//  SplitDetailViweController.m
//  Currency_PAD
//
//  Created by Aries on 15/4/22.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import "SplitDetailViweController.h"

#import "BEMSimpleLineGraphView.h"
#import "ChangesViewController.h"
#import "BEMlineCell.h"
#import "Util.h"
#import "BaseValueView.h"

#import "AppPurcahseViewController.h"

#import <pop/POP.h>

@interface SplitDetailViweController ()<BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    __weak IBOutlet UIButton *leftCurrencyBut;
    __weak IBOutlet UIButton *rightCurrencyBut;
    
    NSString  *beginDate;
    NSString  *endDate;
    NSString *datestring;
    NSString *valuestring;
    BOOL    isLeftSelected;
    BOOL    isRightSelected;
    
    __weak IBOutlet UIButton *settingButton;
    int   leftCount;
    int   rightCount;
    
    int   indexButton;
    CGFloat    height;
    int   interval;
}


//  图表
@property (weak, nonatomic) IBOutlet UIView *cycleView;
@property (weak, nonatomic) IBOutlet UIView *topItemView;

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraphView;
@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;

@property (weak, nonatomic) IBOutlet UILabel *maxValueLable;
@property (nonatomic,strong) UITableView *currencyTable;

@property (nonatomic,retain) NSMutableArray  *currencyArray;
@property (nonatomic,retain) NSMutableArray  *keepArray;

@property  (nonatomic,retain) NSString  *timeString;

// 基准

@property (weak, nonatomic) IBOutlet UIView *baseView;

@property (weak, nonatomic) IBOutlet UIScrollView *baseScrollView;
@property  (nonatomic,retain)  NSMutableArray  *simpleArray;
@property (nonatomic,retain) NSMutableDictionary  *currencyInfor;
@property (nonatomic,retain)  NSMutableDictionary  *resultDic;


@end

@implementation SplitDetailViweController

- (IBAction)showSetting:(id)sender {
    
    UINavigationController  *nv = [self.storyboard   instantiateViewControllerWithIdentifier:@"setttingVC"];;
    
    nv.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController   *popover = nv.popoverPresentationController;
    nv.preferredContentSize = CGSizeMake(350, IPHONE_HEIGHT);
    popover.sourceView = self.view;
    popover.sourceRect = CGRectMake(100,100,0,0);
    
    [self  presentViewController:nv animated:YES completion:^{
    }];
    
}


- (IBAction)changTheCycleAction:(id)sender {
    
    UIButton  *timeBut = (UIButton*)sender;
    NSString *title = timeBut.titleLabel.text;
    indexButton = (int)timeBut.tag - 20150301;
    
    NSTimeInterval  cycleTime;
    if ([title  isEqualToString:@"1W"]) {
        cycleTime = 24*60*60*6;
        interval = 1;
    }else if ([title  isEqualToString:@"1M"]){
        cycleTime = 24*60*60*1*30;
        interval = 8;
    }else if([title  isEqualToString:@"3M"]){
        cycleTime = 24*60*60*3*30;
        interval = 25;
    }else if ([title  isEqualToString:@"6M"]){
        cycleTime = 24*60*60*6*30;
        interval = 25;
    }else if ([title  isEqualToString:@"1Y"]){
        cycleTime = 24*60*60*12*30;
        interval = 30;
    }else if ([title  isEqualToString:@"2Y"]){
        cycleTime = 24*60*60*30*24;
        interval = 30;
    }
    
    [self   addPopAnimationForButton:timeBut];
    [self  takeDateByTimeInterval:cycleTime];
    [self  sendRequestWithTime:beginDate andEndTime:endDate andCurrcncy:leftCurrencyBut.titleLabel.text andBaseCurrency:rightCurrencyBut.titleLabel.text];
}

- (void)takeDateByTimeInterval:(NSTimeInterval)timeInterval{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate  *nowDate = [NSDate  date];
    NSTimeInterval  timeInvercal1 = nowDate.timeIntervalSince1970;
    
    NSTimeInterval   timeInterval2 = timeInvercal1 - timeInterval;
    
    beginDate = [dateFormatter  stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval2 ]];
    endDate = [dateFormatter  stringFromDate:nowDate];
}

- (NSString*)changeDateFormat:(NSString*)dateString {
    
    NSLocale *theLocale = [NSLocale  localeWithLocaleIdentifier:[Localisator sharedInstance].currentLanguage];

    NSString  *localeIdenfifer = [theLocale  objectForKey:NSLocaleIdentifier];
    
    NSDateFormatter * dateFormatter1 = [[NSDateFormatter alloc]init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
    NSDate  *date = [dateFormatter1  dateFromString:dateString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle=kCFDateFormatterMediumStyle;
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdenfifer];
    [dateFormatter setLocale:usLocale];
    
    NSString  *changeResult = [dateFormatter stringFromDate:date];
    return changeResult;
}


- (void)addPopAnimationForButton:(UIButton*)sender{
    
    for (int i = 0;i<7;i++) {
        UIButton  *button = (UIButton*)[self.cycleView   viewWithTag:20150301 + i];
        if ([button  isKindOfClass:[UIButton  class]]) {
            if (button.tag != sender.tag) {
                [button  setAlpha:0.4];
                button.titleLabel.font = [UIFont  fontWithName:@"HelveticaNeue" size:18.0];
                [button setTitleColor:[Util  colorWithHexString:@"#b5b5b5"] forState:UIControlStateNormal];
            }else{
                button.titleLabel.font = [UIFont  fontWithName:@"HelveticaNeue" size:23.0];
                [button  setTitleColor:[Util shareInstance].themeColor forState:UIControlStateNormal];
            }
        }
    }
    
    POPBasicAnimation  *aplaAnimation = [POPBasicAnimation  animation];
    aplaAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPViewAlpha];
    
    POPBasicAnimation  *scaleAnimation = [POPBasicAnimation animation];
    scaleAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayerScaleXY];
    
    POPBasicAnimation  *scaleEndAnimation = [POPBasicAnimation animation];
    scaleEndAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayerScaleXY];
    
    scaleAnimation.toValue = [NSValue  valueWithCGPoint:CGPointMake(1.2, 1.2)];
    scaleAnimation.duration = 0.15;
    
    scaleEndAnimation.toValue = [NSValue  valueWithCGPoint:CGPointMake(1.0, 1.0)];
    scaleEndAnimation.duration = 0.15;
    
    aplaAnimation.toValue = [NSNumber  numberWithInt:1];
    aplaAnimation.duration = 0.15;
    
    scaleEndAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
        }
    };
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [sender.layer  pop_addAnimation:scaleEndAnimation forKey:@"scaleEndAnimation"];
        }
    };
    [sender  pop_addAnimation:aplaAnimation forKey:@"aplaAnimation"];
    [sender.layer  pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

- (IBAction)quickChangeAction:(UIButton *)sender {
    
    NSString  *left = leftCurrencyBut.titleLabel.text;
    NSString  *right = rightCurrencyBut.titleLabel.text;
    [leftCurrencyBut  setTitle:right forState:UIControlStateNormal];
    [rightCurrencyBut  setTitle:left forState:UIControlStateNormal];
    
    if (isRightSelected) {
        [self.currencyArray  removeObject:rightCurrencyBut.titleLabel.text];
        [self.currencyArray  addObject:leftCurrencyBut.titleLabel.text];
    }else if (isLeftSelected){
        [self.currencyArray  removeObject:leftCurrencyBut.titleLabel.text];
        [self.currencyArray  addObject:rightCurrencyBut.titleLabel.text];
    }
    
    [self.currencyTable  reloadData];
    
    [self  runSpinAnimationOnView:sender duration:0.5 rotations:1.0 repeat:1];
    [self  sendRequestWithTime:beginDate andEndTime:endDate andCurrcncy:leftCurrencyBut.titleLabel.text andBaseCurrency:rightCurrencyBut.titleLabel.text];
}


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


- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.timeString = [NSString stringWithFormat:@"2018-01-01"];

    self.arrayOfValues = [NSMutableArray  array];
    self.arrayOfDates = [NSMutableArray  array];
    self.currencyArray = [NSMutableArray  arrayWithArray:[Util  takeSelectedCountry]];
    self.keepArray = [NSMutableArray  array];
    [self  takeDateByTimeInterval:24*60*60*30];
    interval = 8;
    indexButton = 1;
    leftCount = 0;
    rightCount = 0;
    
    UIButton*  button = (UIButton*)[self.cycleView  viewWithTag:20150302];
    [button  setTitleColor:[Util  shareInstance].themeColor forState:UIControlStateNormal];
    
    [self  setPropretyForGraphView];
    [self drawCurrencyTableInterFace];
    [self  addSwipeGesture];
    
    self.simpleArray = [NSMutableArray  arrayWithArray:[Util  takeSelectedCountry]];
    self.currencyInfor = [self  takeCurrencyInfor];

    [self  addobserverForSpliDetail];
    
    [self  takeScheduledTimeRequest];
    
}


- (void)addobserverForSpliDetail{
    
    [[NSNotificationCenter  defaultCenter]  addObserver:self selector:@selector(selectedCurrecyChanged:) name:@"CurrencyChanged" object:nil];
    [[NSNotificationCenter  defaultCenter]  addObserver:self selector:@selector(selectedColorChanged:) name:@"SelectedColorChanged" object:nil];
    [[NSNotificationCenter  defaultCenter]  addObserver:self selector:@selector(dataTypeChanged:) name:@"DataTypeChanged" object:nil];
    [[NSNotificationCenter  defaultCenter]  addObserver:self selector:@selector(dataTypeChanged:) name:@"DefaultValueChanged" object:nil];

}


- (void)viewWillAppear:(BOOL)animated{
    [self  drawNav];
    [self setPropretyForGraphView];
    [self  sendRequestWithTime:beginDate andEndTime:endDate andCurrcncy:leftCurrencyBut.titleLabel.text   andBaseCurrency:rightCurrencyBut.titleLabel.text];
    self.edgesForExtendedLayout =  UIRectEdgeNone;
    
    [settingButton  setBackgroundImage:[[UIImage imageNamed:@"设置.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [settingButton  setTintColor:[Util shareInstance].themeColor];
    
    self.navigationController.navigationBar.tintColor = [Util shareInstance].themeColor;
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem.tintColor = [Util shareInstance].themeColor;
    
    
    NSString  *currenctCurrency = [[Util takeSelectedCountry]  objectAtIndex:0];
    [self  calculateValueUnderBaseCurrency:currenctCurrency AndValue:[Util  readDefaultValue]];
    [self  addbaseCurrencyList:currenctCurrency withValue:[Util  readDefaultValue]];

}

- (void)setPropretyForGraphView{
   
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 0.3,  // 起始位置    红、绿、蓝、透明度
        1.0, 1.0, 1.0, 0.0   // 结束位置    红、绿、蓝、透明度
    };
    self.myGraphView.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    self.cycleView.backgroundColor = [UIColor  whiteColor];
    self.topItemView.backgroundColor = [UIColor  whiteColor];
    
    self.myGraphView.enableTouchReport = YES;
    self.myGraphView.enablePopUpReport = YES;
    self.myGraphView.autoScaleYAxis = YES;
    self.myGraphView.alwaysDisplayDots = NO;
    
    self.myGraphView.enableReferenceXAxisLines = YES;
    self.myGraphView.enableReferenceYAxisLines = YES;
    self.myGraphView.enableReferenceAxisFrame = YES;
    self.myGraphView.animationGraphStyle = BEMLineAnimationDraw;
    
    self.myGraphView.colorReferenceLines =  [UIColor  clearColor] ;
    self.myGraphView.colorTouchInputLine = [Util  shareInstance].themeColor;
    
    self.myGraphView.labelFont = [  UIFont   fontWithName:@"HelveticaNeue" size:16.0];
    
    self.myGraphView.colorBackgroundXaxis = [UIColor  whiteColor];
    self.myGraphView.colorXaxisLabel = [Util  colorWithHexString:@"#a0a0a0"];
    
    self.myGraphView.colorTouchInputLine = [Util  shareInstance].themeColor;
    
    self.myGraphView.colorLine = [Util  shareInstance].themeColor;
    self.myGraphView.colorPoint = [Util  shareInstance].themeColor;
    
    self.myGraphView.popUpAttribueColor = [Util  shareInstance].themeColor;
    
    self.myGraphView.colorTop = [UIColor  clearColor];
    self.myGraphView.colorBottom = [Util  shareInstance].themeColor;
    self.myGraphView.alphaBottom = 0.2;
}


- (void)addbaseCurrencyList:(NSString*)baseCurrency  withValue:(NSString*)value{

    for (UIView  *a  in self.baseScrollView.subviews) {
        [a removeFromSuperview];
    }
    
    self.simpleArray = [Util  takeSelectedCountry];
    
    for (int i = 0; i < self.simpleArray.count; i++) {
        NSString  *currncy = [self.simpleArray  objectAtIndex:i];
        BaseValueView  *view = [[BaseValueView  alloc ] initWithFrame:CGRectMake(5 + 150*i, 5, 140, 180)];
        view.currencyFlag.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_24.png",currncy]];
        view.currencyName.text = currncy;
        view.baseValue.text = value;
        
        view.targetCurrencyFlag.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_24.png",baseCurrency]];
        view.targetCurrencyName.text = baseCurrency;
         view.targetValue.text = [self.resultDic  objectForKey:currncy];
        [self.baseScrollView  addSubview:view];
    }
    
    self.baseScrollView.contentSize = CGSizeMake(self.simpleArray.count*150, self.baseScrollView.frame.size.height);

}

- (void)addSwipeGesture{
    
    UISwipeGestureRecognizer  *swipeLeftGesture = [[UISwipeGestureRecognizer  alloc ] initWithTarget:self action:@selector(swipeAction:)];
    swipeLeftGesture.direction =  UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGesture.delegate = self;
    swipeLeftGesture.numberOfTouchesRequired  = 2;
    [self.view  addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer  *swipeRightGesture = [[UISwipeGestureRecognizer  alloc ] initWithTarget:self action:@selector(swipeAction:)];
    swipeRightGesture.direction =  UISwipeGestureRecognizerDirectionRight;
    swipeRightGesture.delegate = self;
    swipeRightGesture.numberOfTouchesRequired  = 2;
    [self.view  addGestureRecognizer:swipeRightGesture];
    
}

- (void)swipeAction:(UISwipeGestureRecognizer*)sender{
    
    NSString  *productIdPlus = @"plus";
    NSString  *productIdChart = @"chart";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL  is_buy = [[defaults  objectForKey:productIdPlus]  boolValue];
    BOOL  is_chart = [[defaults  objectForKey:productIdChart]  boolValue];
    
    if (!is_buy && !is_chart) {
        return;
    }
    
    UISwipeGestureRecognizer  *swipe = sender;
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (indexButton > 0 && indexButton<= 5) {
            indexButton = indexButton - 1;
        }
    }else if (swipe.direction == UISwipeGestureRecognizerDirectionRight){
        if (indexButton < 5 && indexButton>= 0) {
            indexButton = indexButton + 1;
        }
    }
    UIButton  *button = (UIButton*)[self.cycleView  viewWithTag:20150301 + indexButton];
    [self  changTheCycleAction:button];
    
}

- (void)drawNav{
    
    NSString  *currencyChart = [Util  takeCurrencyForChartView];
    NSArray  *selectedCurrency = [Util   takeSelectedCountry];
    if (selectedCurrency.count >= 2) {
        NSString  *first = [selectedCurrency  objectAtIndex:0];
        if ([first  isEqualToString:currencyChart]) {
            [leftCurrencyBut  setTitle:first forState:UIControlStateNormal];
            [rightCurrencyBut  setTitle:[selectedCurrency  objectAtIndex:1] forState:UIControlStateNormal];
            
        }else{
            if (currencyChart != nil) {
                [leftCurrencyBut  setTitle:currencyChart forState:UIControlStateNormal];
                [rightCurrencyBut  setTitle:first forState:UIControlStateNormal];
                
                if (![self.currencyArray  containsObject:currencyChart]) {
                    [self.currencyArray  addObject:currencyChart];
                }
                
            }else{
                [leftCurrencyBut  setTitle:first forState:UIControlStateNormal];
                [rightCurrencyBut  setTitle:[selectedCurrency  objectAtIndex:1] forState:UIControlStateNormal];
            }
        }
    }else{
        NSString  *first = [selectedCurrency  objectAtIndex:0];
        if (currencyChart != nil) {
            [leftCurrencyBut  setTitle:currencyChart forState:UIControlStateNormal];
            [rightCurrencyBut  setTitle:first forState:UIControlStateNormal];
            if (![self.currencyArray  containsObject:currencyChart]) {
                [self.currencyArray  addObject:currencyChart];
            }
        }else{
            [leftCurrencyBut  setTitle:first forState:UIControlStateNormal];
            [rightCurrencyBut  setTitle:first forState:UIControlStateNormal];
        }
    }
    
    self.keepArray = self.currencyArray;
}


- (void)drawCurrencyTableInterFace{

    int  selectedaCount = (int)[Util  takeSelectedCountry].count - 1;
    height = 30*selectedaCount;
    
    self.currencyTable = [[UITableView alloc ] initWithFrame:CGRectMake(self.view.frame.size.width/2-102,43, 45, height) style:UITableViewStylePlain];
    self.currencyTable.dataSource = self;
    self.currencyTable.delegate = self;
    self.currencyTable.userInteractionEnabled = YES;
    self.currencyTable.scrollEnabled = YES;
    self.currencyTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currencyTable.showsVerticalScrollIndicator = YES;
    self.currencyTable.backgroundColor = [UIColor  whiteColor];
    [self.view  addSubview:self.currencyTable];
    [self.view  bringSubviewToFront:self.currencyTable];
    self.currencyTable.hidden = YES;
    
    [self.currencyTable.layer  setBorderWidth:1.0f];
    [self.currencyTable.layer setCornerRadius:8.0f];
    [self.currencyTable.layer setBorderColor:[UIColor  clearColor].CGColor];
    
    UIButton  * button = (UIButton*)[self.topItemView  viewWithTag:20150507];
    [button  setImage:[[UIImage  imageNamed:@"refresh.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [button  setTintColor:[Util  colorWithHexString:@"#434343"]];
    
}

- (IBAction)chooseCurrencyAction:(UIButton*)sender{
    
    NSString  *productIdPlus = @"plus";
    NSString  *productIdChart = @"chart";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL  is_buy = [[defaults  objectForKey:productIdPlus]  boolValue];
    BOOL  is_chart = [[defaults  objectForKey:productIdChart]  boolValue];
    
    if (is_buy || is_chart) {
        
        if (sender == leftCurrencyBut) {
            if (!isLeftSelected) {
                isLeftSelected = YES;
                isRightSelected = NO;
            }
            leftCount ++;
            rightCount = 0;
            self.currencyTable.frame = CGRectMake(self.view.frame.size.width/2 - 102,43, 45, 1);
        }else{
            
            if (!isRightSelected) {
                isRightSelected = YES;
                isLeftSelected = NO;
            }
            rightCount ++;
            leftCount = 0;
            self.currencyTable.frame = CGRectMake(self.view.frame.size.width/2 + 58,43, 45, 1);
        }
        
        [self  takeOutCurrentCurrency:sender.titleLabel.text];
        
        POPBasicAnimation  *basicAnimation = [POPBasicAnimation   animation];
        basicAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPViewFrame];
        basicAnimation.duration = 0.25;
        
        if (isLeftSelected) {
            if (leftCount%2 == 1) {
                basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43,45, 1)];
                basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43, 45, height)];
                self.currencyTable.hidden = NO;
            }else{
                basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43,45, height)];
                basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43, 45, 1)];
                self.currencyTable.hidden = YES;
            }
        }else if (isRightSelected){
            if (rightCount%2 == 1) {
                basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x, 43,45, 1)];
                basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x, 43, 45, height)];
                self.currencyTable.hidden = NO;
            }else{
                basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x, 43,45, height)];
                basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x, 43, 45, 1)];
                self.currencyTable.hidden = YES;
            }
        }
        [self.currencyTable   pop_addAnimation:basicAnimation forKey:@"CurrencyTableFrame"];
        
    }else{
        
        UIAlertView  *alert = [[UIAlertView  alloc ] initWithTitle:LOCALIZATION(@"UpgradeAlert_Title") message:LOCALIZATION(@"UpgradeAlert_Message") delegate:self cancelButtonTitle:LOCALIZATION(@"UpgradeAlert_CancleButton") otherButtonTitles:LOCALIZATION(@"UpgradeAlert_SureButton"), nil];
        [alert  show];
        
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([alertView.message   isEqualToString:LOCALIZATION(@"UpgradeAlert_Message")]) {
        if (buttonIndex == 1) {
            AppPurcahseViewController  *appPurchase = [[AppPurcahseViewController  alloc ] initWithNibName:@"AppPurcahseViewController" bundle:nil];
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController  pushViewController:appPurchase animated:YES];
        }else{
            
            NSString  *productIdPlus = @"plus";
            NSString  *productIdChart = @"chart";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL  is_buy = [[defaults  objectForKey:productIdPlus]  boolValue];
            BOOL  is_chart = [[defaults  objectForKey:productIdChart]  boolValue];
            
            if (!is_chart && !is_buy) {
                BOOL    isExpire = [Util takeTimeDifference:self.timeString];
                if (isExpire) {
                    UIAlertView  *alertView = [[UIAlertView alloc ] initWithTitle:LOCALIZATION(@"AppPurchaseFreeAlert_Title") message:LOCALIZATION(@"AppPurchaseFreeAlert_Message") delegate:self cancelButtonTitle:nil otherButtonTitles:LOCALIZATION(@"AppPurchaseFreeAlert_RateButton"),LOCALIZATION(@"AppPurchaseFreeAlert_CancleButton"), nil];
                    alertView.cancelButtonIndex = 1;
                    [alertView show];
                }
            }
        }
    }else{
        
        if (buttonIndex == 0) {
            NSString *str = [NSString stringWithFormat:
                             @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=946607423&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
            for (NSString *product in @[@"plus",@"chart"]) {
                [Util  saveAppPurchaseStateWithProductID:product];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:product];
                [defaults synchronize];
            }
        }
    }
}

- (void)takeOutCurrentCurrency:(NSString*)currency{
    
    NSMutableArray  *selectedArray = [NSMutableArray  arrayWithArray:self.keepArray];
    if ([selectedArray  containsObject:currency]) {
        [selectedArray  removeObject:currency];
    }
    self.currencyArray = selectedArray;
    [self.currencyTable  reloadData];
}


- (void)sendRequestWithTime:(NSString*)beginningTime andEndTime:(NSString*)endTime andCurrcncy:(NSString*)currency andBaseCurrency:(NSString*)baseCurrcncy{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString  *urlString = [NSString stringWithFormat:@"http://currencies.apps.grandtrunk.net/getrange/%@/%@/%@/%@",beginningTime,endTime,currency,baseCurrcncy];
        NSURL  *url = [NSURL  URLWithString:urlString];
        NSURLRequest  *request = [NSURLRequest  requestWithURL:url];
        NSError  *error = nil;
        NSData  *receiveData = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:&error];
        NSString   *reciastring = [[NSString  alloc ] initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSArray  *array = [reciastring   componentsSeparatedByString:@"\n"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self  dealWithRequestData:array];
        });
        
    });
}

- (void)dealWithRequestData:(NSArray*)dataArray{
    
    self.arrayOfDates = [NSMutableArray  array];
    [self.arrayOfValues  removeAllObjects];
    for (int i = 0; i < dataArray.count; i++) {
        NSString  *dataString = [dataArray  objectAtIndex:i];
        NSArray  *array = [dataString  componentsSeparatedByString:@" "];
        if (array.count == 2) {
            NSString  *dateString = [array  objectAtIndex:0];
            NSString *valueString = [array  objectAtIndex:1];
            [self.arrayOfDates  addObject:dateString];
            [self.arrayOfValues  addObject:valueString];
        }
    }
    
    if (self.arrayOfDates.count != 0 && self.arrayOfValues.count != 0) {
        [self.myGraphView  reloadGraph];
         [self  performSelector:@selector(findOutMaxAndMinValue) withObject:nil afterDelay:2.55];
    }
}

- (void)findOutMaxAndMinValue{

    float minimumValue =[self.myGraphView calculateMinimumPointValue].floatValue;
    float maximumValue = [self.myGraphView calculateMaximumPointValue].floatValue;
    
    NSString  *max = [NSString stringWithFormat:@"H:%.4f",maximumValue];
    NSString  *min =  [NSString stringWithFormat:@"L:%.4f",minimumValue];
    self.maxValueLable.text = [NSString  stringWithFormat:@"%@    %@",max,min];
}


#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.arrayOfValues objectAtIndex:index] floatValue];
}

-(NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph{
    return 3;
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return interval;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    if (index == 0 || index == self.arrayOfDates.count - 1) {
        return @"";
    }
    NSString *label = [self.arrayOfDates objectAtIndex:index];
    return [self  changeDateFormat:label];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    
    if (self.arrayOfDates.count != 0 && self.arrayOfValues.count != 0) {
        if (index < self.arrayOfDates.count) {
            datestring = [self  changeDateFormat:[self.arrayOfDates  objectAtIndex:index]];
        }
        if (index < self.arrayOfValues.count) {
            valuestring = [self.arrayOfValues  objectAtIndex:index];
        }
    }
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        } completion:nil];
    }];
}


- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    
    if (datestring == nil) {
        if (self.arrayOfDates.count != 0) {
            datestring  = [self.arrayOfDates  objectAtIndex:0];
        }
    }
    return datestring;
}

- (NSString*)noDataLabelTextForLineGraph:(BEMSimpleLineGraphView *)graph{
    return @"Loading Data";
}


#pragma mark
#pragma mark    UITableViewDataSource,UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currencyArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static   NSString *idString = @"SelectCurrencyCell";
    BEMlineCell  *cell = [tableView  dequeueReusableCellWithIdentifier:idString];
    if (cell == nil) {
        cell = [[[NSBundle  mainBundle]  loadNibNamed:@"BEMlineCell" owner:self options:nil]  objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.currencyName.text = [self.currencyArray  objectAtIndex:indexPath.row];
    cell.currencyName.textColor = [Util  colorWithHexString:@"#434343"];
    cell.currencyName.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString  *currency = [self.currencyArray  objectAtIndex:indexPath.row];
    
    if (isLeftSelected) {
        [leftCurrencyBut  setTitle:currency forState:UIControlStateNormal];
        isLeftSelected = NO;
        leftCount = 0;
    }else{
        [rightCurrencyBut  setTitle:currency forState:UIControlStateNormal];
        isRightSelected = NO;
        rightCount = 0;
    }
    
    POPBasicAnimation  *basicAnimation = [POPBasicAnimation   animation];
    basicAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPViewFrame];
    basicAnimation.duration = 0.25;
    basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43, 45, height)];
    basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43, 45, 1)];
    basicAnimation.completionBlock =^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            self.currencyTable.hidden = YES;
            [self  sendRequestWithTime:beginDate andEndTime:endDate andCurrcncy:leftCurrencyBut.titleLabel.text andBaseCurrency:rightCurrencyBut.titleLabel.text];
        }
    };
    [self.currencyTable   pop_addAnimation:basicAnimation forKey:@"CurrencyTableFrame"];
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark
#pragma mark   汇率计算

- (void)calculateValueUnderBaseCurrency:(NSString*)targetCurrency AndValue:(NSString*)baseValue{
    
    NSMutableDictionary  *valueDic = [NSMutableDictionary  dictionary];
    NSDictionary  *rateDic = [Util   takeAllCountryInfor];
    NSString *baseRate = [rateDic  objectForKey:targetCurrency];
    
     self.simpleArray = [Util  takeSelectedCountry];

    for (int i = 0; i < self.simpleArray.count; i++) {
        NSString *unitString = [self.simpleArray   objectAtIndex:i];
        NSString  *   currentRate = [rateDic  objectForKey:unitString];
        int   dataType  = [Util shareInstance].dataType;
        float  resultFloat = [Util  numberFormatterForFloat:baseValue]/[currentRate doubleValue]*[baseRate  doubleValue];
        NSString  *result = [Util  roundUp:resultFloat afterPoint:dataType];
        [valueDic setObject:[Util   numberFormatterSetting:result withFractionDigits:dataType withInput:NO] forKey:unitString];
    }
    self.resultDic = valueDic;
}

- (NSMutableDictionary*)takeCurrencyInfor{
    NSMutableDictionary   *inforDic = [NSMutableDictionary  dictionary];
    NSArray  *allCurrency = [Util  readQuestionData];
    for (NSDictionary   *dic  in allCurrency) {
        NSString  *currencyAbbName = [dic   objectForKey:@"currencyAbbreviated"];
        if ([self.simpleArray containsObject:currencyAbbName]) {
            [inforDic  setObject:dic forKey:currencyAbbName];
        }
    }
    return inforDic;
}



- (void)takeScheduledTimeRequest{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString  *urlString = [NSString stringWithFormat:@"%s","http://121.40.203.232:8080/FetationWeb/apptime/time"];
        NSURL  *url = [NSURL  URLWithString:urlString];
        NSURLRequest  *request = [NSURLRequest  requestWithURL:url];
        NSError  *error = nil;
        NSData  *receiveData = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:&error];
        if (receiveData != nil || error == nil) {
            NSDictionary  *dataDic = [NSJSONSerialization  JSONObjectWithData:receiveData options:NSJSONReadingMutableContainers error:&error];
            if (error== nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.timeString = [dataDic  objectForKey:@"updatetime"];
                });
            }
        }
    });
    
}


#pragma mark
#pragma mark      NSNotification 
- (void)selectedCurrecyChanged:(NSNotification*)sender{
    
    int  selectedaCount = (int)[Util  takeSelectedCountry].count - 1;
    height = 30*selectedaCount;
    
    self.currencyTable.frame = CGRectMake(self.currencyTable.frame.origin.x, self.currencyTable.frame.origin.y, self.currencyTable.frame.size.width, height);
    
    self.currencyArray = [NSMutableArray  arrayWithArray:[Util  takeSelectedCountry]];
    [self  drawNav];
    [self.currencyTable  reloadData];
    
    self.simpleArray = [Util  takeSelectedCountry];
    self.currencyInfor = [self  takeCurrencyInfor];
    
    NSString  *currenctCurrency = [[Util takeSelectedCountry]  objectAtIndex:[Util  takeSelectedIndex].row];
    [self  calculateValueUnderBaseCurrency:currenctCurrency AndValue:[Util  readDefaultValue]];
    [self  addbaseCurrencyList:currenctCurrency withValue:[Util  readDefaultValue]];

}


- (void)selectedColorChanged:(NSNotification*)sender{
    [self setPropretyForGraphView];
    [self  sendRequestWithTime:beginDate andEndTime:endDate andCurrcncy:leftCurrencyBut.titleLabel.text   andBaseCurrency:rightCurrencyBut.titleLabel.text];
    [settingButton  setTintColor:[Util  shareInstance].themeColor];
    
    UIButton  *button  = (UIButton*)[self.cycleView  viewWithTag:indexButton + 20150301];
    [button setTitleColor:[Util shareInstance].themeColor forState:UIControlStateNormal];
    
}

- (void)dataTypeChanged:(NSNotification*)sender{
    NSString  *currenctCurrency = [[Util takeSelectedCountry]  objectAtIndex:[Util  takeSelectedIndex].row];
    [self  calculateValueUnderBaseCurrency:currenctCurrency AndValue:[Util  readDefaultValue]];
    [self  addbaseCurrencyList:currenctCurrency withValue:[Util  readDefaultValue]];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
   }


@end
