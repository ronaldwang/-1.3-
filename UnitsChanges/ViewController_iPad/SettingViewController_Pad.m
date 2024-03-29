//
//  SettingViewController.m
//  Currency_PAD
//
//  Created by Aries on 15/5/7.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import "SettingViewController_Pad.h"

#import <MessageUI/MessageUI.h>

#import "Util.h"
#import <pop/POP.h>
#import "CustomerUITextField.h"
#import "ASBanker.h"

#import "AppPurcahseViewController.h"
#import "LanguageViewController.h"
#import "TtpsViewController.h"

#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface SettingViewController_Pad ()<MFMailComposeViewControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    BOOL    isTaped;
    BOOL   isEditing;
}

@property (weak, nonatomic) IBOutlet UIView *themeView;
@property (weak, nonatomic) IBOutlet UIView *themeColorView;

@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (weak, nonatomic) IBOutlet UIView *defaultView;

@property (weak, nonatomic) IBOutlet UIView *numberView;

@property (weak, nonatomic) IBOutlet UIView *upgradeView;

@property (weak, nonatomic) IBOutlet UILabel *upgradeLable;

@property (weak, nonatomic) IBOutlet CustomerUITextField *defaultValueInputText;

@property (weak, nonatomic) IBOutlet UILabel *decimalsLable;

@property (weak, nonatomic) IBOutlet UILabel *langiageLable;

@property (weak, nonatomic) IBOutlet UISwitch *soundKeepSwitch;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *themeViewWidthConstraint;

@property  (nonatomic,strong) NSMutableArray  *colorArray;

@property (weak, nonatomic) IBOutlet UIView *praiseView;
@property (weak, nonatomic) IBOutlet UIView *mailView;

@property (weak, nonatomic) IBOutlet UILabel *defaultlable;
@property (weak, nonatomic) IBOutlet UILabel *keyBoardlable;

@property (weak, nonatomic) IBOutlet UILabel *numberLable;
@property (weak, nonatomic) IBOutlet UILabel *colorLable;

@property (weak, nonatomic) IBOutlet UILabel *languageLable;

@property (weak, nonatomic) IBOutlet UIView *languageView;

@property (weak, nonatomic) IBOutlet UILabel *feedBackLable;
@property (weak, nonatomic) IBOutlet UILabel *rateUsLable;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numberToColorVerConstraint;

// 反馈
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipsVerticalToFeedbackConstraints;

@property (weak, nonatomic) IBOutlet UILabel *rightsContentLable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightsContentVerticalConstraints;


@property (nonatomic,retain) NSMutableString  *textFieldText;
@property (nonatomic,retain)  NSString  *timeString;

//  输入 键盘
@property (weak, nonatomic) IBOutlet UIView *keyBoardView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyBoardViewVerConstraint;



@end

@implementation SettingViewController_Pad

- (IBAction)keepingSoundsAction:(UISwitch *)sender {
    
    [[NSUserDefaults  standardUserDefaults]  setBool:sender.on forKey:@"isKeepingSound"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.colorArray = [NSMutableArray arrayWithObjects:@"#20c0fa",@"#f42061",@"#0ba287",@"#fd7a11",@"#771efd",@"#15bd39",@"#efcf1d",@"#f641c1",@"#00dbb3",nil];
    
    self.timeString = [NSString stringWithFormat:@"2018-01-01"];
    
    [self  drawNavigationBarv];
    
    [self drawViewContraint];
    [self setViewContstraints];
    
    [self  addShadowForCalcuatorView];
    
    [self  addColorButtonsOnScrollview:self.colorArray];
    
    //  摇一摇
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //摇动结束
    if (event.subtype == UIEventSubtypeMotionShake) {
        
        NSMutableArray  *themeArray = [Util shareInstance].themeArray;
        int   themeIndex = arc4random() % themeArray.count;
        NSString  *theme = [themeArray  objectAtIndex:themeIndex];
        [Util  shareInstance].themeColor = [Util  colorWithHexString:theme];
        [Util  saveColorString:theme];
        [Util  saveColorByNSUserDefaults:theme];
        
        self.navigationController.navigationBar.tintColor = [Util shareInstance].themeColor;
        self.soundKeepSwitch.onTintColor = [Util shareInstance].themeColor;
        self.themeColorView.backgroundColor = [Util shareInstance].themeColor;
        self.defaultValueInputText.tintColor = [Util shareInstance].themeColor;
        [self.themeColorView.layer  setBorderColor:[Util shareInstance].themeColor.CGColor];
        [self  addPopAnmationForNav];
        
        [self  addPopViewAniamtion];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super  viewWillAppear:animated];
    [self  setStrartValue];
    self.navigationController.navigationBar.tintColor = [Util shareInstance].themeColor;
     [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,[UIFont  fontWithName:@"HelveticaNeue-Light" size:20],NSFontAttributeName,nil]];
    [self  addPopAnmationForNav];
    [self  addPopViewAniamtion];
    [self  setLocalLanguage];
    
    [self takeScheduledTimeRequest];
    
}

- (void)setStrartValue{
    
    self.themeColorView.backgroundColor = [Util  shareInstance].themeColor;
    [self.themeColorView.layer  setBorderColor:[Util  shareInstance].themeColor.CGColor];
    self.defaultValueInputText.text = [Util  readDefaultValue];
    
    self.textFieldText = [NSMutableString  stringWithFormat:@"%d",(int)[Util  numberFormatterForFloat:self.defaultValueInputText.text]];
    
    self.defaultValueInputText.tintColor = [Util  shareInstance].themeColor;
    
//    self.defaultValueInputText.inputAccessoryView = [self  createToolbar];
    

    self.soundKeepSwitch.onTintColor = [Util  shareInstance].themeColor;
    
    int  decimals = [Util takeDataType];
    if (decimals == 0) {
        self.decimalsLable.text = @"0";
    }else if (decimals == 1){
        self.decimalsLable.text = @"0.0";
    }else if (decimals == 2){
        self.decimalsLable.text = @"0.00";
    }else if (decimals == 3){
        self.decimalsLable.text = @"0.000";
    }else if (decimals == 4){
        self.decimalsLable.text = @"0.0000";
    }
    
    BOOL  isKeepingSound = [Util  isKeepingSound];
    self.soundKeepSwitch.on = isKeepingSound;
    self.langiageLable.text = LOCALIZATION([Localisator sharedInstance].currentLanguage);
}

// 本地化字符串
- (void)setLocalLanguage{
    self.colorLable.text = LOCALIZATION(@"color");
    self.numberLable.text =  LOCALIZATION(@"number");
    self.languageLable.text = LOCALIZATION(@"LanguageVCTitle");
    self.feedBackLable.text = LOCALIZATION(@"Feedback");
    self.rateUsLable.text = LOCALIZATION(@"Rate us");
    self.rightsContentLable.text = LOCALIZATION(@"RightsMessage");
    self.defaultlable.text = LOCALIZATION(@"DefaultValue");
    self.keyBoardlable.text = LOCALIZATION(@"KeypadTone");
    self.upgradeLable.text = LOCALIZATION(@"Upgrade");

}

- (void)setViewContstraints{
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];

    self.contentViewHeightConstraint.constant = 700;
    self.mainScrollview.contentSize = CGSizeMake(IPHONE_WIDTH, self.contentViewHeightConstraint.constant);
}

- (void)drawViewContraint{
    
    self.praiseView.tintColor = [Util  shareInstance].themeColor;
    self.praiseView.backgroundColor = [Util shareInstance].themeColor;
    self.mailView.tintColor = [Util shareInstance].themeColor;
    self.mailView.backgroundColor = [Util shareInstance].themeColor;
    
    [self.feedBackLable  sizeToFit];
    [self.rateUsLable  sizeToFit];
    
    self.feedBackLable.adjustsFontSizeToFitWidth = YES;
    self.rateUsLable.adjustsFontSizeToFitWidth = YES;
    
    [self.praiseView.layer  setBorderWidth:1.0f];
    [self.praiseView.layer setBorderColor:[Util shareInstance].themeColor.CGColor];
    [self.praiseView.layer  setCornerRadius:17.0f];
    
    [self.mailView.layer  setBorderWidth:1.0f];
    [self.mailView.layer setBorderColor:[Util shareInstance].themeColor.CGColor];
    [self.mailView.layer  setCornerRadius:17.0f];
    
    [self.themeColorView.layer  setBorderWidth:1.0f];
    [self.themeColorView.layer setBorderColor:[Util shareInstance].themeColor.CGColor];
    [self.themeColorView.layer  setCornerRadius:16.0f];
    
    UITapGestureRecognizer  *praiseTap = [[UITapGestureRecognizer  alloc ] initWithTarget:self action:@selector(praiseAction:)];
    [self.praiseView  addGestureRecognizer:praiseTap];
    
    UITapGestureRecognizer  *mailTap = [[UITapGestureRecognizer  alloc ] initWithTarget:self action:@selector(mailAction:)];
    [self.mailView  addGestureRecognizer:mailTap];
    
    
    UITapGestureRecognizer  *decimalsTap = [[UITapGestureRecognizer  alloc ] initWithTarget:self action:@selector(decimalsAction:)];
    [self.numberView   addGestureRecognizer:decimalsTap];
    
    
    UITapGestureRecognizer  *defaultValueTap = [[UITapGestureRecognizer  alloc ] initWithTarget:self action:@selector(defaultValueAction:)];
    [self.defaultView   addGestureRecognizer:defaultValueTap];
    
    
    UITapGestureRecognizer  *lanuageTap = [[UITapGestureRecognizer  alloc ] initWithTarget:self action:@selector(languageAction:)];
    [self.languageView  addGestureRecognizer:lanuageTap];
    
    UITapGestureRecognizer  *upgradeTap = [[UITapGestureRecognizer  alloc ] initWithTarget:self action:@selector(upgradeAction:)];
    [self.upgradeView   addGestureRecognizer:upgradeTap];
    
    
    UITapGestureRecognizer  *themeTap = [[UITapGestureRecognizer  alloc ] initWithTarget:self action:@selector(themeAction:)];
    [self.colorView  addGestureRecognizer:themeTap];
    
    
    UITapGestureRecognizer  *contentViewTap = [[UITapGestureRecognizer  alloc ] initWithTarget:self action:@selector(contentViewTapAction:)];
    [self.contentView  addGestureRecognizer:contentViewTap];
    
}


// App Store 评论
- (void)praiseAction:(UITapGestureRecognizer*)sender{
    
    if (isEditing) {
        [self  textFieldDone];
        return;
    }
    
    NSString *str = [NSString stringWithFormat:
                     @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=946607423&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}

// 意见反馈--邮件
- (void)mailAction:(UITapGestureRecognizer*)sender{
    
    if (isEditing) {
        [self  textFieldDone];
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    if (!picker) {
        // 在设备还没有添加邮件账户的时候mailViewController为空，下面的present view controller会导致程序崩溃，这里要作出判断
        [[UIApplication  sharedApplication]  openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
        return;
    }
    
    [picker setSubject:LOCALIZATION(@"Feedback")];
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"davetech.app@gmail.com"];
    
    [picker setToRecipients:toRecipients];
    
    [self presentViewController:picker animated:YES completion:^{
    }];
}


// 默认值设置
- (void)defaultValueAction:(UITapGestureRecognizer*)sender{
    
    NSString  *productIdPlus = @"plus";
    NSString  *productIdChart = @"chart";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL  is_buy = [[defaults  objectForKey:productIdPlus]  boolValue];
    BOOL  is_chart = [[defaults  objectForKey:productIdChart]  boolValue];
    
    if (is_buy || is_chart) {
        self.defaultValueInputText.enabled = YES;
        [self.defaultValueInputText  becomeFirstResponder];
    }else{
        self.defaultValueInputText.enabled = NO;
        
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

//  设置小数点
- (void)decimalsAction:(UITapGestureRecognizer*)sender{
    
    if (isEditing) {
        [self  textFieldDone];
        return;
    }
    
    LanguageViewController    *languageVC = [[LanguageViewController  alloc ] initWithNibName:@"LanguageViewController" bundle:nil];
    languageVC.isLanguage = NO;
    [self.navigationController  pushViewController:languageVC animated:YES];
    
}

// 设置语言
- (void)languageAction:(UITapGestureRecognizer*)sender{
    
    if (isEditing) {
        [self  textFieldDone];
        return;
    }
    
    LanguageViewController    *languageVC = [[LanguageViewController  alloc ] initWithNibName:@"LanguageViewController" bundle:nil];
    languageVC.isLanguage = YES;
    
    [self.navigationController  pushViewController:languageVC animated:YES];
    
}

//  设置主题颜色
- (void)themeAction:(UITapGestureRecognizer*)sender{
    
    if (isEditing) {
        [self  textFieldDone];
        return;
    }
    
    isTaped  = !isTaped;
    
    POPBasicAnimation  *constraintAnimation = [POPBasicAnimation  animation];
    constraintAnimation.property = [POPMutableAnimatableProperty  propertyWithName:kPOPLayoutConstraintConstant];
    constraintAnimation.duration = 0.5;
    if (isTaped) {
        constraintAnimation.fromValue = [NSNumber  numberWithInt:0];
        constraintAnimation.toValue = [NSNumber  numberWithInt:240];
        self.contentViewHeightConstraint.constant = 900;
    }else{
        constraintAnimation.fromValue = [NSNumber  numberWithInt:240];
        constraintAnimation.toValue = [NSNumber  numberWithInt:0];
        self.contentViewHeightConstraint.constant = 700;
    }
    
    [self.numberToColorVerConstraint   pop_addAnimation:constraintAnimation forKey:@"constraintColor"];
    
    self.mainScrollview.contentSize = CGSizeMake(IPHONE_WIDTH, self.contentViewHeightConstraint.constant);
    
}

// 升级版本-内购页面
- (void)upgradeAction:(UITapGestureRecognizer*)sender{
    
    if (isEditing) {
        [self  textFieldDone];
        return;
    }
    
    AppPurcahseViewController  *appPurchase = [[AppPurcahseViewController  alloc ] initWithNibName:@"AppPurcahseViewController" bundle:nil];
    [self.navigationController  pushViewController:appPurchase animated:YES];
    
}

- (void)contentViewTapAction:(UITapGestureRecognizer*)sender{
    if (isEditing) {
        [self  textFieldDone];
    }
}


#pragma  amrk   设置 导航 栏
//  设置 导航 栏
- (void)drawNavigationBarv{
    
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 12, 20);
    [button  setBackgroundImage:[[UIImage imageNamed:@"forward.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
   //   UIImageRenderingMode   设置tintColor 时,图片的颜色可以根据此属性随设置的tintColor改变
    
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem   *leftItem = [[UIBarButtonItem  alloc ]  initWithCustomView:button];
    [self.navigationItem  setLeftBarButtonItem:leftItem animated:YES];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

//   返回
- (void)backAction:(UIButton*)sender{
    if (isEditing) {
        [self  textFieldDone];
    }
   [self.navigationController popViewControllerAnimated:YES];
}

#pragma amrk    设置按钮  弧度
//  设置按钮  弧度
- (void)drawDataTypeButtonInterFace{
    
    int  dataType = [Util shareInstance].dataType + 2010;
    UIView  *view  = [self.view  viewWithTag:20014];
    UIButton  *button = (UIButton*)[view  viewWithTag:2010];
    [button.layer  setBorderWidth:0.0f];
    if (dataType == button.tag) {
        [button.layer setBorderColor:[Util  shareInstance ] .themeColor.CGColor];
        [button setTitleColor:[UIColor  whiteColor] forState:UIControlStateNormal];
        
    }else{
        [button.layer  setBorderColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0].CGColor];
        [button setBackgroundColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
        [button setTitleColor:[UIColor  lightGrayColor] forState:UIControlStateNormal];
    }
    [button.layer setCornerRadius:20.0f];
    [button.layer  setMasksToBounds:YES];
    
    UIButton  *button1 = (UIButton*)[view  viewWithTag:2011];
    [button1.layer  setBorderWidth:0.0f];
    if (dataType == button1.tag) {
        [button1.layer setBorderColor:[Util  shareInstance ] .themeColor.CGColor];
        [button1 setTitleColor:[UIColor  whiteColor] forState:UIControlStateNormal];
    }else{
        [button1.layer  setBorderColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0].CGColor];
        [button1 setBackgroundColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
        [button1 setTitleColor:[UIColor  lightGrayColor] forState:UIControlStateNormal];
    }
    [button1.layer setCornerRadius:20.0f];
    [button1.layer  setMasksToBounds:YES];
    
    UIButton  *button2 = (UIButton*)[view  viewWithTag:2012];
    [button2.layer  setBorderWidth:0.0f];
    if (dataType == button2.tag) {
        [button2.layer setBorderColor:[Util  shareInstance ] .themeColor.CGColor];
        [button2 setTitleColor:[UIColor  whiteColor] forState:UIControlStateNormal];
    }else{
        [button2.layer  setBorderColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0].CGColor];
        [button2 setBackgroundColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
        [button2 setTitleColor:[UIColor  lightGrayColor] forState:UIControlStateNormal];
    }
    [button2.layer setCornerRadius:20.0f];
    [button2.layer  setMasksToBounds:YES];
    
    UIButton  *button3 = (UIButton*)[view  viewWithTag:2013];
    [button3.layer  setBorderWidth:0.0f];
    if (dataType == button3.tag) {
        [button3.layer setBorderColor:[Util  shareInstance ] .themeColor.CGColor];
        [button3 setTitleColor:[UIColor  whiteColor] forState:UIControlStateNormal];
    }else{
        [button3.layer  setBorderColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0].CGColor];
        [button3 setBackgroundColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
        [button3 setTitleColor:[UIColor  lightGrayColor] forState:UIControlStateNormal];
    }
    [button3.layer setCornerRadius:20.0f];
    [button3.layer  setMasksToBounds:YES];
    
    UIButton  *button4 = (UIButton*)[view  viewWithTag:2014];
    [button4.layer  setBorderWidth:0.0f];
    if (dataType == button4.tag) {
        [button4.layer setBorderColor:[Util  shareInstance ] .themeColor.CGColor];
        [button4 setTitleColor:[UIColor  whiteColor] forState:UIControlStateNormal];
    }else{
        [button4.layer  setBorderColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0].CGColor];
        [button4 setBackgroundColor:[UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
        [button4 setTitleColor:[UIColor  lightGrayColor] forState:UIControlStateNormal];
    }
    [button4.layer setCornerRadius:20.0f];
    [button4.layer  setMasksToBounds:YES];
}

#pragma mark   颜色 按钮  布局
//   颜色 按钮  布局
- (void)addColorButtonsOnScrollview:(NSArray*)colorArray{
    float  space = (self.themeViewWidthConstraint.constant - 50*3 - 40)/2;
    int k = 0;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j< 3; j++) {
            if (k > colorArray.count - 1) {
                return;
            }
            NSString  *colorString = [colorArray  objectAtIndex:k];
            UIButton* button = [UIButton  buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [Util  colorWithHexString:colorString];
            button.frame = CGRectMake(space*j + 50*j + 20, 15 + 70*i, 50, 50);
            [button addTarget:self action:@selector(selectThemeColorAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = k + 9999;
            [button.layer  setBorderWidth:0.0f];
            [button.layer setCornerRadius:25.0f];
            [button.layer setBorderColor:[Util  colorWithHexString:colorString].CGColor];
            [button.layer  setMasksToBounds:YES];
            [self.themeView  addSubview:button];
            k++;
        }
    }
}

#pragma mark   选中主题颜色
//  选中主题颜色
- (void)selectThemeColorAction:(UIButton*)sender{
    
    [self  addPopAnimationForColorButton:sender];
    [Util  shareInstance].themeColor = sender.backgroundColor;
    [Util saveColorString:[self.colorArray  objectAtIndex:sender.tag - 9999]];
    [Util  saveColorByNSUserDefaults:[self.colorArray  objectAtIndex:sender.tag - 9999]];
    [self.mainScrollview  saveColorString:[self.colorArray  objectAtIndex:sender.tag - 9999]];
    self.themeColorView.backgroundColor = sender.backgroundColor;
    [self.themeColorView.layer  setBorderColor:sender.backgroundColor.CGColor];
    [self  addPopAnmationForNav];
    [self  addPopViewAniamtion];
    self.soundKeepSwitch.onTintColor = [Util shareInstance].themeColor;
    self.defaultValueInputText.tintColor = [Util shareInstance].themeColor;

    [[NSNotificationCenter  defaultCenter]  postNotificationName:@"SelectedColorChanged" object:nil];
    
}

#pragma mark  设置导航栏  tintColor  POP 动画
//  设置导航栏  tintColor  POP 动画
- (void)addPopAnmationForNav{
    
    POPBasicAnimation  *tintColorAnimation = [POPBasicAnimation  animation];
    tintColorAnimation.property = [POPMutableAnimatableProperty  propertyWithName:kPOPViewTintColor];
    tintColorAnimation.duration = 0.15;
    tintColorAnimation.toValue = [Util shareInstance].themeColor;
    [self.navigationController.navigationBar   pop_addAnimation:tintColorAnimation forKey:@"tintColor"];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,nil]];
    
}

#pragma mark  选中主题颜色 按钮  动画
//  选中主题颜色 按钮  动画
- (void)addPopAnimationForColorButton:(UIButton*)sender{
    
    POPBasicAnimation  *scaleAnimation = [POPBasicAnimation animation];
    scaleAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayerScaleXY];
    POPBasicAnimation  *scaleEndAnimation = [POPBasicAnimation animation];
    scaleEndAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue  valueWithCGPoint:CGPointMake(1.5, 1.5)];
    scaleEndAnimation.toValue = [NSValue  valueWithCGPoint:CGPointMake(1.0, 1.0)];
    scaleAnimation.duration = 0.15;
    scaleEndAnimation.duration = 0.15;
    
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [sender.layer  pop_addAnimation:scaleEndAnimation forKey:@"scaleEnd"];
        }
    };
    [sender.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    
}

#pragma mark  为数据 类型 按钮  添加  动画 （背景色）
//  为数据 类型 按钮  添加  动画 （背景色）
- (void)addPopBackgroundColorForDataType:(UIButton*)sender{
    
    POPBasicAnimation  *backColorAnimation = [POPBasicAnimation  animation];
    backColorAnimation.property = [POPMutableAnimatableProperty  propertyWithName:kPOPViewBackgroundColor];
    backColorAnimation.duration = 0.0;
    backColorAnimation.toValue = [Util shareInstance].themeColor;
    [sender   pop_addAnimation:backColorAnimation forKey:@"backGroundColor"];
}

#pragma mark  设置 layer  borderColor  动画
// 设置 layer  borderColor  动画
- (void)addPopButtonLayerAnimation:(UIButton*)sender withColor:(UIColor*)color{
    
    POPBasicAnimation  *borderColorAnimation = [POPBasicAnimation  animation];
    borderColorAnimation.property = [POPMutableAnimatableProperty  propertyWithName:kPOPLayerBorderColor];
    borderColorAnimation.duration = 0.5;
    borderColorAnimation.toValue = color;
    [sender.layer   pop_addAnimation:borderColorAnimation forKey:@"borderGroundColor"];
    
}

- (void)addPopViewAniamtion{
    
    POPBasicAnimation  *backColorAnimation = [POPBasicAnimation  animation];
    backColorAnimation.property = [POPMutableAnimatableProperty  propertyWithName:kPOPViewBackgroundColor];
    backColorAnimation.duration = 0.2;
    backColorAnimation.toValue = [Util shareInstance].themeColor;
    
    POPBasicAnimation  *borderColorAnimation = [POPBasicAnimation  animation];
    borderColorAnimation.property = [POPMutableAnimatableProperty  propertyWithName:kPOPLayerBorderColor];
    borderColorAnimation.duration = 0.2;
    borderColorAnimation.toValue = [Util shareInstance].themeColor;
    
    [self.praiseView.layer   pop_addAnimation:borderColorAnimation forKey:@"borderGroundColor"];
    [self.mailView.layer   pop_addAnimation:borderColorAnimation forKey:@"borderGroundColor"];
    
    [self.praiseView  pop_addAnimation:backColorAnimation forKey:@"backColorAnimation"];
    [self.mailView  pop_addAnimation:backColorAnimation forKey:@"backColorAnimation"];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark
#pragma mark   UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (isEditing == NO) {
        textField.textColor = [Util shareInstance].themeColor;
         [self  showOrHidenKeyBoard:YES];
    }
   
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //只输入数字
     if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            return NO;
        }
    
    if (![string  isEqualToString:@""]) {
        if (self.textFieldText.length <=9) {
            [self.textFieldText  appendString:string];
        }
    }else{
        if (self.textFieldText.length >=1) {
            [self.textFieldText deleteCharactersInRange:NSMakeRange(self.textFieldText.length - 1, 1)];
        }
    }
    
    textField.text = [Util  numberFormatterSetting:[NSString  stringWithFormat:@"%f",[Util numberFormatterForFloat:self.textFieldText]] withFractionDigits:2 withInput:YES];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self  textFieldDone];
    return NO;

}

- (void)textFieldDone{
    
    if (self.defaultValueInputText.text.length != 0) {
        [Util  saveDefaultVauleByNsuer:self.defaultValueInputText.text];
        
        [[NSNotificationCenter  defaultCenter ] postNotificationName:@"DefaultValueChanged" object:nil];
        
    }else{
        self.defaultValueInputText.text = [Util readDefaultValue];
    }
    
    self.defaultValueInputText.textColor = [UIColor darkGrayColor];
    [self   showOrHidenKeyBoard:NO];

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
#pragma mark      输入键盘

- (IBAction)keyBoardClick:(UIButton *)sender {
    
    [self   addPopAnaitionClickButton:sender];
    
    if ([Util  isKeepingSound]) {
        AudioServicesPlaySystemSound(0x450);  //  系统自带按键声音
    }
    
    NSString  *inputString = sender.titleLabel.text;
    
    if (self.textFieldText.length <=9) {
        [self.textFieldText  appendString:inputString];
    }
    
    self.defaultValueInputText.text = [Util  numberFormatterSetting:[NSString  stringWithFormat:@"%f",[Util numberFormatterForFloat:self.textFieldText]] withFractionDigits:2 withInput:YES];

}

- (IBAction)okButtonClick:(UIButton *)sender {
    if ([Util  isKeepingSound]) {
        AudioServicesPlaySystemSound(0x450);  //  系统自带按键声音
    }
    [self   addPopAnaitionClickButton:sender];
    [self  textFieldDone];
}

- (IBAction)clearClick:(UIButton *)sender {
    if ([Util  isKeepingSound]) {
        AudioServicesPlaySystemSound(0x450);  //  系统自带按键声音
    }
    [self   addPopAnaitionClickButton:sender];
    self.textFieldText = [NSMutableString string];
    self.defaultValueInputText.text = @"0";
}

- (void)showOrHidenKeyBoard:(BOOL)show{
    
    isEditing = show;

    POPBasicAnimation   *basicAnimation = [POPBasicAnimation animation];
    basicAnimation.property = [POPMutableAnimatableProperty  propertyWithName:kPOPLayoutConstraintConstant];
    basicAnimation.duration = 0.5;
    
    if (show) {
         basicAnimation.fromValue = [NSNumber numberWithFloat:1200];
         basicAnimation.toValue = [NSNumber numberWithFloat:IPHONE_HEIGHT - self.keyBoardView.frame.size.height - 64];
    }else{
        basicAnimation.fromValue = [NSNumber numberWithFloat:IPHONE_HEIGHT - self.keyBoardView.frame.size.height - 64];
         basicAnimation.toValue = [NSNumber numberWithFloat:1200];
    }
    
    [self.keyBoardViewVerConstraint   pop_addAnimation:basicAnimation forKey:@"KeyBoardViewVerConstraint"];
    
}


- (void)addPopAnaitionClickButton:(UIButton*)button{
    
    POPBasicAnimation  *colcorAnimation = [POPBasicAnimation animation];
    colcorAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLabelTextColor];
    POPBasicAnimation  *scaleAnimation = [POPBasicAnimation animation];
    scaleAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayerScaleXY];
    POPBasicAnimation  *scaleEndAnimation = [POPBasicAnimation animation];
    scaleEndAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayerScaleXY];
    POPBasicAnimation  *colcorEndAnimation = [POPBasicAnimation animation];
    colcorEndAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLabelTextColor];
    colcorAnimation.toValue = [Util shareInstance].themeColor;
    colcorEndAnimation.toValue = [UIColor  colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:1.0];
    scaleAnimation.toValue = [NSValue  valueWithCGPoint:CGPointMake(1.5, 1.5)];
    scaleEndAnimation.toValue = [NSValue  valueWithCGPoint:CGPointMake(1.0, 1.0)];
    colcorAnimation.duration = 0.15f;
    scaleEndAnimation.duration = 0.15;
    scaleAnimation.duration = 0.15;
    colcorEndAnimation.duration = 0.15;
    colcorEndAnimation.fromValue = [Util shareInstance].themeColor;
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [button.layer  pop_addAnimation:scaleEndAnimation forKey:@"scaleEnd"];
        }
    };
    colcorAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [button.titleLabel  pop_addAnimation:colcorEndAnimation forKey:@"colorEnd"];
        }
    };
    [button.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    [button.titleLabel  pop_addAnimation:colcorAnimation forKey:@"pop"];
    
}


- (void)addShadowForCalcuatorView{
    [self.keyBoardView.layer  setShadowOffset:CGSizeMake(0,-0.5)];
    [self.keyBoardView.layer setShadowRadius:0.25];
    [self.keyBoardView.layer  setShadowOpacity:0.08];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
