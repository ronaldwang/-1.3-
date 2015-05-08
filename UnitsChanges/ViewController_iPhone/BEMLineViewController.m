//
//  BEMLineViewController.m
//  Currenci
//
//  Created by Aries on 15/3/6.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "BEMLineViewController.h"
#import "BEMSimpleLineGraphView.h"
#import "ChangesViewController.h"
#import "BEMlineCell.h"
#import "UIViewController+Tutorial.h"
#import "Util.h"
#import "AppDelegate.h"
#import <pop/POP.h>

@interface BEMLineViewController ()<BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    __weak IBOutlet UIButton *leftCurrencyBut;
    __weak IBOutlet UIButton *rightCurrencyBut;
    __weak IBOutlet UIButton *wangGeBut;
    __weak IBOutlet UIImageView *backImage;

    NSString  *beginDate;
    NSString  *endDate;
    NSString *datestring;
    NSString *valuestring;
    BOOL    isLeftSelected;
    BOOL    isRightSelected;
    
    int   leftCount;
    int   rightCount;
    
    int   indexButton;
    CGFloat    height;
    int   interval;
}

@property (weak, nonatomic) IBOutlet UIView *cycleView;
@property (weak, nonatomic) IBOutlet UIView *topItemView;

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraphView;
@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;

@property (weak, nonatomic) IBOutlet UILabel *maxValueLable;
@property (nonatomic,strong) UITableView *currencyTable;

@property (nonatomic,retain) NSMutableArray  *currencyArray;
@property (nonatomic,retain) NSMutableArray  *keepArray;

@end

@implementation BEMLineViewController


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
    
    NSLocale *theLocale = [NSLocale currentLocale];
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
                button.titleLabel.font = [UIFont  fontWithName:@"HelveticaNeue" size:12.0];
            }else{
               button.titleLabel.font = [UIFont  fontWithName:@"HelveticaNeue" size:20.0];
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


- (IBAction)backAction:(id)sender {
    
     [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self  customerTutorial];
    
    self.arrayOfValues = [NSMutableArray  array];
    self.arrayOfDates = [NSMutableArray  array];
    self.currencyArray = [NSMutableArray  arrayWithArray:[Util  takeSelectedCountry]];
    self.keepArray = [NSMutableArray  array];
    [self  takeDateByTimeInterval:24*60*60*30];
    interval = 8;
    indexButton = 1;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 0.3,  // 起始位置    红、绿、蓝、透明度
        1.0, 1.0, 1.0, 0.0   // 结束位置    红、绿、蓝、透明度
    };
    self.myGraphView.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    self.cycleView.backgroundColor = [Util  shareInstance].themeColor;
    self.topItemView.backgroundColor = [Util  shareInstance].themeColor;

    self.myGraphView.enableTouchReport = YES;
    self.myGraphView.enablePopUpReport = YES;
    self.myGraphView.autoScaleYAxis = YES;
    self.myGraphView.alwaysDisplayDots = NO;
    
    self.myGraphView.enableReferenceXAxisLines = YES;
    self.myGraphView.enableReferenceYAxisLines = YES;
    self.myGraphView.enableReferenceAxisFrame = YES;
    self.myGraphView.animationGraphStyle = BEMLineAnimationDraw;
    
    self.myGraphView.colorReferenceLines =  [UIColor  clearColor] ;
    
    self.myGraphView.popUpAttribueColor = [Util  shareInstance].themeColor;
    self.myGraphView.colorTop = [Util  shareInstance].themeColor;
    self.myGraphView.colorBottom = [Util  shareInstance].themeColor;
    self.view.backgroundColor = [Util shareInstance].themeColor;
    
    leftCount = 0;
    rightCount = 0;
    
    
    [self drawCurrencyTableInterFace];
    [self  addSwipeGesture];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self  drawNav];
    [self  sendRequestWithTime:beginDate andEndTime:endDate andCurrcncy:leftCurrencyBut.titleLabel.text   andBaseCurrency:rightCurrencyBut.titleLabel.text];
    self.edgesForExtendedLayout =  UIRectEdgeNone;
    
    // pageViewController
    AppDelegate  *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (UIScrollView   *scrollView  in  delegate.pageViewController.view.subviews ) {
        scrollView.scrollEnabled = NO;
    }
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
    
    [wangGeBut  setBackgroundImage:[[UIImage  imageNamed:@"网格.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    backImage.image = [[UIImage  imageNamed:@"返回.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    backImage.tintColor = [UIColor  whiteColor];
}


- (void)drawCurrencyTableInterFace{
    
    int  selectedaCount = (int)[Util  takeSelectedCountry].count;
    if (selectedaCount >= 4) {
        height = 120;
    }else if (selectedaCount >= 2 && selectedaCount<4){
        height = 30*selectedaCount;
    }else{
        height = 60;
    }
    
    self.currencyTable = [[UITableView alloc ] initWithFrame:CGRectMake(self.view.frame.size.width/2-30,43, 40, height) style:UITableViewStylePlain];
    self.currencyTable.dataSource = self;
    self.currencyTable.delegate = self;
    self.currencyTable.userInteractionEnabled = YES;
    self.currencyTable.scrollEnabled = YES;
    self.currencyTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currencyTable.showsVerticalScrollIndicator = NO;
    self.currencyTable.backgroundColor = [Util  shareInstance].themeColor;
    [self.view  addSubview:self.currencyTable];
    [self.view  bringSubviewToFront:self.currencyTable];
    self.currencyTable.hidden = YES;
    
    [self.currencyTable.layer  setBorderWidth:1.0f];
    [self.currencyTable.layer setCornerRadius:8.0f];
    [self.currencyTable.layer setBorderColor:[Util  shareInstance].themeColor.CGColor];
}


- (void)customerTutorial{
    
    NSString *tutorialKey = [NSString stringWithFormat:@"%@_tutorial", NSStringFromClass ([self class])];
    BOOL wasShown = [[NSUserDefaults standardUserDefaults] boolForKey:tutorialKey];
    
    if (wasShown) {
        return;
    }
    
    int64_t delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self  startTutorialWithInfo:LOCALIZATION(@"LongPressMessage") atPoint:CGPointMake(IPHONE_WIDTH/2, IPHONE_HEIGHT/2 - 40) withFingerprintStartingPoint:CGPointMake(IPHONE_WIDTH/2 - 80 , IPHONE_HEIGHT/2 + 20) andEndPoint:CGPointMake(IPHONE_WIDTH/2 + 80, IPHONE_HEIGHT/2 + 20) shouldHideBackground:NO completion:^{
        }];
    });

}

- (IBAction)chooseCurrencyAction:(UIButton*)sender{
    
    if (sender == leftCurrencyBut) {
        if (!isLeftSelected) {
            isLeftSelected = YES;
            isRightSelected = NO;
        }
        leftCount ++;
        rightCount = 0;
        self.currencyTable.frame = CGRectMake(self.view.frame.size.width/2 - 64,43, 40, 1);
    }else{
        
        if (!isRightSelected) {
            isRightSelected = YES;
            isLeftSelected = NO;
        }
        rightCount ++;
        leftCount = 0;
        self.currencyTable.frame = CGRectMake(self.view.frame.size.width/2 + 26,43, 40, 1);
    }

   [self  takeOutCurrentCurrency:sender.titleLabel.text];
    
    POPBasicAnimation  *basicAnimation = [POPBasicAnimation   animation];
    basicAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPViewFrame];
    basicAnimation.duration = 0.25;
    
    if (isLeftSelected) {
        if (leftCount%2 == 1) {
            basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43,40, 1)];
            basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43, 40, height)];
             self.currencyTable.hidden = NO;
        }else{
            basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43,40, height)];
            basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43, 40, 1)];
             self.currencyTable.hidden = YES;
        }
    }else if (isRightSelected){
        if (rightCount%2 == 1) {
            basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x, 43,40, 1)];
            basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x, 43, 40, height)];
            self.currencyTable.hidden = NO;
        }else{
            basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x, 43,40, height)];
            basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x, 43, 40, 1)];
            self.currencyTable.hidden = YES;
        }
    }
    [self.currencyTable   pop_addAnimation:basicAnimation forKey:@"CurrencyTableFrame"];
}

- (void)takeOutCurrentCurrency:(NSString*)currency{
    
     NSMutableArray  *selectedArray = [NSMutableArray  arrayWithArray:self.keepArray];
    if ([selectedArray  containsObject:currency]) {
        [selectedArray  removeObject:currency];
    }
    self.currencyArray = selectedArray;
    [self.currencyTable  reloadData];
}


- (IBAction)showGriddingAction:(UIButton*)sender{
    self.myGraphView.enableXAxisLabel = !self.myGraphView.enableXAxisLabel;
    self.myGraphView.enableYAxisLabel = !self.myGraphView.enableYAxisLabel;
    
    self.myGraphView.colorReferenceLines = (self.myGraphView.enableYAxisLabel == YES? [UIColor  whiteColor]:[UIColor  clearColor]) ;
    
    [self.myGraphView  reloadGraph];
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
        [self  performSelector:@selector(findOutMaxAndMinValue) withObject:nil afterDelay:1.55];
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
        datestring = [self  changeDateFormat:[self.arrayOfDates  objectAtIndex:index]];
        valuestring = [self.arrayOfValues  objectAtIndex:index];
    }
  }

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    } completion:^(BOOL finished) {

        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        } completion:nil];
    }];
}


- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    
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
    basicAnimation.fromValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43, 40, height)];
    basicAnimation.toValue = [NSValue   valueWithCGRect:CGRectMake(self.currencyTable.frame.origin.x,43, 40, 1)];
    basicAnimation.completionBlock =^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            self.currencyTable.hidden = YES;
            [self  sendRequestWithTime:beginDate andEndTime:endDate andCurrcncy:leftCurrencyBut.titleLabel.text andBaseCurrency:rightCurrencyBut.titleLabel.text];
        }
    };
    [self.currencyTable   pop_addAnimation:basicAnimation forKey:@"CurrencyTableFrame"];
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChangesViewController *changesVC = [storyboard instantiateViewControllerWithIdentifier:@"ChangesViewController"];
    [self  preformTransitionToViewController:changesVC direction:kCATransitionFromTop];
}


- (void)preformTransitionToViewController:(UIViewController*)dest direction:(NSString*)direction {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = direction; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    NSMutableArray *stack = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stack removeLastObject];
    [stack addObject:dest];
    [self.navigationController setViewControllers:stack animated:NO];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
      return YES;
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
