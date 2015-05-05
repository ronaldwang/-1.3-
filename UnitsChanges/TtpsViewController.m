//
//  TtpsViewController.m
//  Currenci
//
//  Created by Aries on 15/2/6.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "TtpsViewController.h"
#import "Util.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
@interface TtpsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintForContentView;


@property (weak, nonatomic) IBOutlet UILabel *shakeLable;

@property (weak, nonatomic) IBOutlet UILabel *targetLable;

@property (weak, nonatomic) IBOutlet UILabel *targetDetailLable;


@property (weak, nonatomic) IBOutlet UILabel *shakeMessage;
@property (weak, nonatomic) IBOutlet UILabel *swipe;
@property (weak, nonatomic) IBOutlet UILabel *swipeRightMessage;
@property (weak, nonatomic) IBOutlet UILabel *holdAndDrag;
@property (weak, nonatomic) IBOutlet UILabel *holdAndDragMessage;
@property (weak, nonatomic) IBOutlet UILabel *swipeLeft;
@property (weak, nonatomic) IBOutlet UILabel *swipeLeftMessage;
@property (weak, nonatomic) IBOutlet UILabel *swipeOnSearch;
@property (weak, nonatomic) IBOutlet UILabel *swipeOnSearchMessage;

@property (weak, nonatomic) IBOutlet UILabel *longPressLable;

@property (weak, nonatomic) IBOutlet UILabel *longPressMessage;



@end

@implementation TtpsViewController

- (void)backAction:(UIButton*)sender{
    [self  dismissViewControllerAnimated:YES completion:^{
    }];
    
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self  setMainScrollViewContentViewConstraint];
    [self drawNavigationBarv];
    [self  takeLableContent];
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
        [self.mainScrollView  saveColorString:theme];
        
        self.navigationController.navigationBar.tintColor = [Util shareInstance].themeColor;
        self.view.backgroundColor = [Util shareInstance].themeColor;
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,[UIFont  fontWithName:@"HelveticaNeue-Light" size:20],NSFontAttributeName,nil]];
    }
}

- (void)setMainScrollViewContentViewConstraint{

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
    self.mainScrollView.contentSize = CGSizeMake(IPHONE_WIDTH, self.heightConstraintForContentView.constant);
    self.view.backgroundColor = [Util shareInstance].themeColor;
}

- (void)takeLableContent{
    
    self.swipe.text = LOCALIZATION(@"SwipeRight");
    self.swipeRightMessage.text = LOCALIZATION(@"SwipeRightMessage");
    self.swipeLeft.text = LOCALIZATION(@"SwipeLeft");
    self.swipeLeftMessage.text = LOCALIZATION(@"SwipeLeftMessage");
    self.swipeOnSearch.text = LOCALIZATION(@"SwipeRightOnSearch");
    self.swipeOnSearchMessage.text = LOCALIZATION(@"SwipeRightOnSearchMessage");
    self.holdAndDrag.text = LOCALIZATION(@"Hold&Drag");
    self.holdAndDragMessage.text = LOCALIZATION(@"Hold&DragMessage");
    self.shakeLable.text = LOCALIZATION(@"Shake");
    self.shakeMessage.text = LOCALIZATION(@"ShakeMessage");
    
    self.targetLable.text = LOCALIZATION(@"TargertCurrenci");
    self.targetDetailLable.text = LOCALIZATION(@"TargertCurrenciMessage");

    self.longPressLable.text = LOCALIZATION(@"LongPress");
    self.longPressMessage.text = LOCALIZATION(@"LongPressMessage");
    
    self.title = LOCALIZATION(@"TipsTitle");
}

#pragma  amrk   设置 导航 栏
//  设置 导航 栏
- (void)drawNavigationBarv{
    
    for (UIView *parentView in self.navigationController.navigationBar.subviews){
        for (UIView *childView in parentView.subviews){
            if ([childView isKindOfClass:[UIImageView class]])
                [childView removeFromSuperview];
        }
    }
    
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 16, 16);
    [button  setBackgroundImage:[[UIImage imageNamed:@"关闭.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //  UIImageRenderingMode   设置tintColor 时,图片的颜色可以根据此属性随设置的tintColor改变
    
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem   *leftItem = [[UIBarButtonItem  alloc ]  initWithCustomView:button];
     [self.navigationItem  setLeftBarButtonItem:leftItem animated:YES];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,[UIFont  fontWithName:@"HelveticaNeue-Light" size:20],NSFontAttributeName,nil]];
    
    self.navigationController.navigationBar.tintColor = [Util shareInstance].themeColor;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController  navigationBar].layer.shadowOffset = CGSizeMake(2.0f , 2.0f);
    [self.navigationController  navigationBar].layer.shadowOpacity = 0.15f;
    [self.navigationController navigationBar].layer.shadowRadius = 4.0f;
    
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
