//
//  ChangesViewController.m
//  Currency_PAD
//
//  Created by Aries on 15/4/21.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import "ChangesViewController_Pad.h"
#import "Util.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ChangesCell.h"
#import "CurrencyController.h"
#import <pop/POP.h>
#import <AudioToolbox/AudioToolbox.h>

static  int  requestCount = 0;

@interface ChangesViewController_Pad ()<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate,CountryViewControllerDelegate>
{
        NSIndexPath  *stratIndexPath;
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
    BOOL  isAdd;
    double numDisplay;
    NSMutableString *display;
    CGPoint    offSetPoint;
    
    int  screenPanCount;

}
@property (nonatomic,retain)  NSMutableArray  *unitsArray;  //  当前已有的国家
@property (nonatomic,retain) NSMutableDictionary *currencyDic;

@property (nonatomic,retain)  NSMutableArray *allCountryArray; //  所有国家
@property  (nonatomic,retain)  NSMutableDictionary  *flagDic;
@property (nonatomic,retain) NSMutableDictionary *changesDic;

@property (nonatomic,retain)  NSString  *changesResult;  //   计算结果
@property (nonatomic,retain) NSIndexPath  *indexPath;

@property (nonatomic,retain) NSString  *localeSeparator;


@property (weak, nonatomic) IBOutlet UILabel *sayingLable;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;


@property (weak, nonatomic) IBOutlet UIView *calcuatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calcutorViewVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cacutorViewHeightContraint;




@end

@implementation ChangesViewController_Pad


- (IBAction)packUpCalculateView:(UIButton *)sender {
    
    if (sender != nil) {
        [self  changeFlagSatateWith:self.indexPath];
        [self.changeTable  reloadData];
    }
    
    CGFloat  calcuatorViewHeight = self.calcuatorView.frame.size.height;
   
    calcuatorViewHeight = 310;
    
    //  kPOPLayoutConstraintConstant
    POPBasicAnimation   *calcutorViewVerticalAnimation = [POPBasicAnimation  animation];
    calcutorViewVerticalAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayoutConstraintConstant];
    calcutorViewVerticalAnimation.duration = 0.4;
    calcutorViewVerticalAnimation.toValue =  [NSNumber  numberWithFloat:800];
    [self.calcutorViewVerticalConstraint  pop_addAnimation:calcutorViewVerticalAnimation forKey:@"calcutorViewVerticalConstraint"];
    
    POPBasicAnimation  *contentInsetAnimtion = [POPBasicAnimation  animation];
    contentInsetAnimtion.property = [POPAnimatableProperty  propertyWithName:kPOPScrollViewContentInset];
    contentInsetAnimtion.duration = 0.4;
    contentInsetAnimtion.toValue = [NSValue  valueWithUIEdgeInsets:UIEdgeInsetsZero];
    [self.changeTable  pop_addAnimation:contentInsetAnimtion forKey:@"contentInsetAnimtion"];
    
    POPBasicAnimation   *contentOffsetAnimation = [POPBasicAnimation  animation];
    contentOffsetAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPScrollViewContentOffset];
    contentOffsetAnimation.duration = 0.4;
    contentOffsetAnimation.toValue = [NSValue  valueWithCGPoint:offSetPoint];
    contentOffsetAnimation.completionBlock = ^(POPAnimation  *aim,BOOL   finished){
        if (finished) {
            self.calcuatorView.hidden = YES;
            self.changeTable.scrollEnabled = YES;
        }
    };
    [self.changeTable  pop_addAnimation:contentOffsetAnimation forKey:@"contentOffsetAnimation"];
    
}



- (void)selectedCountry:(id)sender{
    
    NSDictionary  *dic = (NSDictionary*)sender;
    NSString  *currency = [dic  objectForKey:@"currencyAbbreviated"];
    
    if (![self.unitsArray  containsObject:currency]) {
        [self.unitsArray addObject:currency];
        [Util  saveSelectedCounrty:self.unitsArray];
        [self  saveSelectCountryForExtension:self.unitsArray];
        [self.flagDic  setObject:@"0" forKey:currency];
        NSString  *rate = [NSString stringWithFormat:@"%.3f",[[self.rateDic   objectForKey:currency]  floatValue]];
        [self.changesDic  setObject:rate forKey:currency];
        [Util  saveChangeDic:self.changesDic];
        [self.changeTable  reloadData];
        
        [[NSNotificationCenter  defaultCenter] postNotificationName:@"CurrencyChanged" object:nil userInfo:nil];
    }
}


- (void)selectedCurrecyChanged:(NSNotification*)notificstion{
    [self  selectedCountry:notificstion.userInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets=NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.tintColor = [Util shareInstance].themeColor;
    
    if ([Util  takeSelectedIndex] == nil) {
        self.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }else{
        self.indexPath = [Util  takeSelectedIndex];
    }
    stratIndexPath = [NSIndexPath  indexPathForRow:0 inSection:0];
    
    self.flagDic = [NSMutableDictionary  dictionary];
    
    if ([Util takeChangeDic] == nil) {
        self.changesDic = [NSMutableDictionary  dictionary];
    }else{
        self.changesDic = [NSMutableDictionary  dictionaryWithDictionary:[Util  takeChangeDic]];
    }
    
    if ([Util takeSelectedCountry].count == 0) {
        self.unitsArray = [NSMutableArray  arrayWithObjects:@"USD",@"EUR",nil];
        [Util  saveSelectedCounrty:self.unitsArray];
    }else{
        self.unitsArray = [NSMutableArray  arrayWithArray:[Util  takeSelectedCountry]];
    }
    
    if ([Util takeAllCountryInfor] == nil) {
        self.rateDic = [NSMutableDictionary dictionary];
        [self  takeDefaultBaseRate:[Util  readQuestionData]];
        [Util saveTextByNSUserDefaults:self.rateDic];
        [Util  saveAllCountryInfor:self.rateDic];
    }
    
    //   请求汇率数据
    [self  ratesAndCountryRequest];
    
    [self  getCurrentCountrey];
    
    self.allCountryArray = [Util  readQuestionData];
    [self  takeCurrencyInfroDic];
    [self  creatMoveGesterRecognizer];
    
    [self takeSayingLableContet];
    
    [[NSNotificationCenter  defaultCenter]  addObserver:self selector:@selector(selectedCurrecyChanged:) name:@"SelectedCurrecyChanged" object:nil];
}


#pragma  mark
#pragma mark    从plist获取 名言
- (NSMutableArray*)takeAllSayingContent{
    NSString  *pathString = [NSString  stringWithFormat:@"saying"];
    NSURL  *url = [[NSBundle  mainBundle]  URLForResource:pathString withExtension:@"plist"];
    NSMutableArray  *array =  [NSMutableArray arrayWithContentsOfURL:url];
    
    [Util  saveSayingContentArray:array];
    return array;
}

- (void)takeSayingLableContet{
    NSArray  *sayingArray = [self   takeAllSayingContent];
    int   sayIndex = arc4random() % sayingArray.count;
    NSDictionary  *sayingDic = [sayingArray  objectAtIndex:sayIndex];
    NSString  *sayingContent = [sayingDic  objectForKey:@"sayingContent"];
    NSString  *name = [sayingDic   objectForKey:@"name"];
    self.sayingLable.text = sayingContent;
    self.nameLable.text = [NSString stringWithFormat:@"—%@",name];
}

#pragma  mark
#pragma  mark   获取当前所在国家
- (void)getCurrentCountrey{
    
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *currencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([[Localisator  sharedInstance].currentLanguage  isEqualToString:@"DeviceLanguage"]) {
        [[Localisator  sharedInstance]  setLanguage:currentLanguage];
        [[Localisator  sharedInstance]  setSaveInUserDefaults:YES];
    }
    self.localeSeparator= [theLocale  objectForKey:NSLocaleDecimalSeparator];
    if (![self.unitsArray  containsObject:currencyCode]) {
        [self.unitsArray insertObject:currencyCode atIndex:0];
        [self  initializeArray];
    }
    [self saveSelectCountryForExtension:self.unitsArray];
    [Util saveSelectedCounrty:self.unitsArray];
}

#pragma mark
#pragma mark     移动手势
- (void)creatMoveGesterRecognizer{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.changeTable addGestureRecognizer:longPress];
}


#pragma mark
#pragma mark    默认值初始化
- (void) initializeArray{
    NSString  *localeRate = [self.rateDic  objectForKey:[[NSLocale  currentLocale]  objectForKey:NSLocaleCurrencyCode]];
    int  dataType = [Util shareInstance].dataType;
    for (int i = 0; i<self.unitsArray.count; i++) {
        NSString  *currencyAbb = [self.unitsArray  objectAtIndex:i];
        [self.flagDic  setObject:@"0" forKey:currencyAbb];
        if ([currencyAbb  isEqualToString:[[NSLocale  currentLocale]  objectForKey:NSLocaleCurrencyCode]]) {
            [self.changesDic setObject:[Util  readDefaultValue] forKey:currencyAbb];
        }else{
            NSString  *rate = [NSString stringWithFormat:@"%f",[[self.rateDic   objectForKey:currencyAbb]  floatValue]];
            float  resultFloat = [[Util  readDefaultValue]  intValue]/[localeRate doubleValue]*[rate  doubleValue];
            NSString * result = [Util  roundUp:resultFloat afterPoint:dataType];
            [self.changesDic setObject:[Util   numberFormatterSetting:result withFractionDigits:dataType withInput:NO] forKey:currencyAbb];
        }
    }
    
    [Util   saveChangeDic:self.changesDic];
}


- (void)resetNumberInput{
    NSString  *localeRate = [self.rateDic  objectForKey:[self.unitsArray objectAtIndex:0]];
    NSString  *baseValue = [NSString  string];
    NSString  *firstValue = [self.changesDic  objectForKey:[self.unitsArray objectAtIndex:0]];
    if ([firstValue   isEqualToString:[Util  readDefaultValue]]) {
        baseValue = firstValue;
    }else{
        if (firstValue == nil) {
            baseValue = [NSString  stringWithFormat:@"%f",[Util  numberFormatterForFloat:[Util  readDefaultValue]]];
        }else{
            baseValue = [NSString  stringWithFormat:@"%f",[Util  numberFormatterForFloat:firstValue]];
        }
    }
    
    int  dataType = [Util shareInstance].dataType;
    for (int i = 0; i<self.unitsArray.count; i++) {
        NSString  *currencyAbb = [self.unitsArray  objectAtIndex:i];
        [self.flagDic  setObject:@"0" forKey:currencyAbb];
        if (i == 0) {
            [self.changesDic setObject:firstValue forKey:currencyAbb];
        }else{
            NSString  *rate = [NSString stringWithFormat:@"%f",[[self.rateDic   objectForKey:currencyAbb]  floatValue]];
            float  resultFloat = [baseValue  doubleValue]/[localeRate doubleValue]*[rate  doubleValue];
            NSString * result = [Util  roundUp:resultFloat afterPoint:dataType];
            [self.changesDic setObject:[Util   numberFormatterSetting:result withFractionDigits:dataType withInput:NO] forKey:currencyAbb];
        }
    }
    
    [Util  saveChangeDic:self.changesDic];
}

- (void)resetNumberUnderMove:(id)sender{
    
    NSString  *localeRate = [self.rateDic  objectForKey:[self.unitsArray objectAtIndex:0]];
    NSString  *baseValue = [Util  readDefaultValue];
    int  dataType = [Util shareInstance].dataType;
    for (int i = 0; i<self.unitsArray.count; i++) {
        NSString  *currencyAbb = [self.unitsArray  objectAtIndex:i];
        [self.flagDic  setObject:@"0" forKey:currencyAbb];
        if (i == 0) {
            [self.changesDic setObject:baseValue forKey:currencyAbb];
        }else{
            NSString  *rate = [NSString stringWithFormat:@"%f",[[self.rateDic   objectForKey:currencyAbb]  floatValue]];
            float  resultFloat = [Util  numberFormatterForFloat:baseValue]/[localeRate doubleValue]*[rate  doubleValue];
            NSString * result = [Util  roundUp:resultFloat afterPoint:dataType];
            [self.changesDic setObject:[Util   numberFormatterSetting:result withFractionDigits:dataType withInput:NO] forKey:currencyAbb];
        }
    }
    
    [Util  saveChangeDic:self.changesDic];
}




// 获取所有的国家信息
- (NSMutableArray*)takeAllCountryInfo{
    NSString  *pathString = [NSString  stringWithFormat:@"country"];
    NSURL  *url = [[NSBundle  mainBundle]  URLForResource:pathString withExtension:@"plist"];
    NSMutableArray  *array =  [NSMutableArray arrayWithContentsOfURL:url];
    return array;
}

- (void)takeDefaultBaseRate:(NSMutableArray*)countryArray{
    for (NSDictionary  *countryDic  in  countryArray) {
        NSString  *rateString = [countryDic  objectForKey:@"rate"];
        NSString  *currencyAbb  = [countryDic  objectForKey:@"currencyAbbreviated"];
        [self.rateDic  setObject:rateString forKey:currencyAbb];
    }
}

#pragma mark
#pragma mark     汇率数据更新
- (void)ratesAndCountryRequest{
    requestCount ++;
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
//                    [self.changeTable  saveRequestDate:[Util  changeDateToStringWith:[NSDate  date]]];
                    self.rateDic = [Util  deaWithRequestData:[dataDic  objectForKey:@"list"]];
                    [Util saveTextByNSUserDefaults:self.rateDic];
                    [Util  saveAllCountryInfor:self.rateDic];
                    [self performSelector:@selector(delayStopAnimation:) withObject:nil afterDelay:0.0];
                    requestCount = 0;
                });
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (requestCount < 2) {
                        [self   ratesAndCountryRequest];
                    }else{
                        [self.changeTable  reloadData];
//                        [self performSelector:@selector(delayRemoveAnimation:) withObject:nil afterDelay:2.0];
                        requestCount = 0;
                    }
                });
            }
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (requestCount < 2) {
                    [self   ratesAndCountryRequest];
                }else{
                    [self.changeTable  reloadData];
//                    [self performSelector:@selector(delayRemoveAnimation:) withObject:nil afterDelay:2.0];
                    requestCount = 0;
                }
            });
        }
    });
}


- (void)delayStopAnimation:(id)sender{

    if (self.unitsArray.count!= 0) {
        NSString *result =[self.changesDic  objectForKey:[self.unitsArray  objectAtIndex:self.indexPath.row]];
        [self  calculateAllSelectedCurrcncyByInput:[NSString  stringWithFormat:@"%f",[Util  numberFormatterForFloat:result]]];
        [self.changeTable  reloadData];
    }
}


#pragma mark
#pragma mark       通过APP Group ID 建立共同的数据读写区，以供extension和containing app数据共享
- (void)saveSelectCountryForExtension:(NSMutableArray*)selectCountry{
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];  // APP Group ID
    [shared setObject:selectCountry forKey:@"selectCountry"];
    [shared synchronize];
    
}

#pragma mark
#pragma mark   所有国家 相关信息
- (NSMutableArray*)takeAllCountry{
    NSString  *pathString = [NSString  stringWithFormat:@"country"];
    NSURL  *url = [[NSBundle  mainBundle]  URLForResource:pathString withExtension:@"plist"];
    NSMutableArray  *array =  [NSMutableArray arrayWithContentsOfURL:url];
    return array;
}

#pragma amrk
#pragma amrk     货币简写
- (NSString*)takeCurrencyAbbed:(NSString*)countryAbbed{
    NSString *currencyAbb = nil;
    for (NSDictionary  * dic in self.allCountryArray) {
        NSString *countryString = [dic  objectForKey:@"countryAbbreviated"];
        if ([countryAbbed  isEqualToString:countryString]) {
            currencyAbb = [dic  objectForKey:@"currencyAbbreviated"];
        }
    }
    return  currencyAbb;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.unitsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 101;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static   NSString  *identifier = @"changes";
    ChangesCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.delegate = self;
    cell.unitValueLable.tag = indexPath.row + 10;
    cell.unitValueLable.adjustsFontSizeToFitWidth = YES;
    cell.unitNameLable.text = [self.unitsArray objectAtIndex:indexPath.row];
    int  flag = [[self.flagDic  objectForKey:[self.unitsArray objectAtIndex:indexPath.row]]  intValue];
    NSString  *unit = [self.unitsArray  objectAtIndex:indexPath.row];
    cell.countryFlag.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",unit]];
    
    cell.currencyName.text = [self  takeCurrencyInfoByName:unit];
    
    if ([unit  isEqualToString:[[NSLocale currentLocale]  objectForKey:NSLocaleCurrencyCode]]) {
        cell.dingWeiImage.image = [UIImage  imageNamed:@"定位.png"];
        cell.dingWeiImage.hidden = NO;
    }else{
        cell.dingWeiImage.hidden = YES;
    }
    int  result = (int)([self.changesResult  doubleValue]*100);
    if (flag == 0) {
        cell.unitValueLable.textColor =  [Util colorWithHexString:@"#434343"];
        NSString  *changesRate = [[Util  takeAllCountryInfor]  objectForKey:unit];
        NSString  *selectedRate = [[Util  takeAllCountryInfor]   objectForKey:[self.unitsArray objectAtIndex:self.indexPath.row]];
        if (result == 0) {
            cell.unitValueLable.text = [self.changesDic  objectForKey:unit];
        }else{
            int   dataType  = [Util shareInstance].dataType;
            float  resultFloat = [self.changesResult  doubleValue]/[selectedRate doubleValue]*[changesRate  doubleValue];
            NSString  *temp = [Util  roundUp:resultFloat afterPoint:dataType];
            cell.unitValueLable.text =[Util   numberFormatterSetting:temp withFractionDigits:dataType withInput:NO];
            [self.changesDic setObject:cell.unitValueLable.text forKey:unit];
        }
    }else{
        
        cell.unitValueLable.textColor =  [Util shareInstance].themeColor;
        if (result == 0) {
            cell.unitValueLable.text = [self.changesDic  objectForKey:unit];
        }else{
            cell.unitValueLable.text =  [Util  numberFormatterSetting:self.changesResult withFractionDigits:4 withInput:YES];
            [self.changesDic setObject:cell.unitValueLable.text forKey:unit];
        }
    }
    return cell;

}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self   deleteChangesCell:indexPath];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self  selectedCurrecyCell:indexPath];
    return indexPath;
    
}


- (void)selectedCurrecyCell:(NSIndexPath*)indexPath{
    
    if (indexPath.row >= self.unitsArray.count) {
        return;
    }
    
    [self  changeFlagSatateWith:indexPath];
    
    if (self.calcuatorView.hidden || [self.indexPath  isEqual:indexPath]) {
        [self  showCalculateViewBy:indexPath];
    }
    
    self.changesResult = @"0";
    self.indexPath = indexPath;
    [Util  saveSelectedIndex:indexPath];
    [self.changeTable  reloadData];
    [self  calculator_init];
    
}

- (void)showCalculateViewBy:(NSIndexPath*)index{
    
    int  flag = [[self.flagDic  objectForKey:[self.unitsArray objectAtIndex:index.row]]  intValue];
    if (flag == 1) {
        offSetPoint = self.changeTable.contentOffset;
        self.calcuatorView.hidden = NO;
        CGFloat  calcuatorViewHeight = self.calcuatorView.frame.size.height;
        calcuatorViewHeight = 310;

        UITableViewCell  *cell = [self.changeTable  cellForRowAtIndexPath:index];
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, calcuatorViewHeight, 0.0);
        
        self.cacutorViewHeightContraint.constant = calcuatorViewHeight;
        
        
        POPBasicAnimation   *calcutorViewVerticalAnimation = [POPBasicAnimation  animation];
        calcutorViewVerticalAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayoutConstraintConstant];
        calcutorViewVerticalAnimation.duration = 0.25;
        calcutorViewVerticalAnimation.toValue =  [NSNumber  numberWithFloat:IPHONE_HEIGHT - calcuatorViewHeight - 64];
        
        //  kPOPScrollViewContentInset 动画
        POPBasicAnimation  *contentInsetAnimtion = [POPBasicAnimation  animation];
        contentInsetAnimtion.property = [POPAnimatableProperty  propertyWithName:kPOPScrollViewContentInset];
        contentInsetAnimtion.duration = 0.25;
        contentInsetAnimtion.toValue = [NSValue  valueWithUIEdgeInsets:contentInsets];
        contentInsetAnimtion.completionBlock = ^(POPAnimation  *aim,BOOL   finished){
            if (finished) {
                [self  performSelector:@selector(preparScrollRectToVisible:) withObject:cell afterDelay:0.0];
                [self.calcutorViewVerticalConstraint  pop_addAnimation:calcutorViewVerticalAnimation forKey:@"calcutorViewVerticalConstraint"];
                self.changeTable.scrollEnabled = NO;
            }
        };
        [self.changeTable  pop_addAnimation:contentInsetAnimtion forKey:@"contentInsetAnimtion"];
        
    }else{
        [self  packUpCalculateView:nil];
    }
}

- (void)preparScrollRectToVisible:(UITableViewCell*)sender{
    
    CGRect aRect = self.changeTable.frame;
    aRect.size.height -= 393;
    if (!CGRectContainsPoint(aRect, sender.frame.origin) ) {
        [self.changeTable scrollRectToVisible:sender.frame animated:YES];
    }
}

- (void)changeFlagSatateWith:(NSIndexPath*)indexPath{
    
    int  flag = [[self.flagDic  objectForKey:[self.unitsArray objectAtIndex:indexPath.row]]  intValue];
    for (int i = 0; i <self.unitsArray.count; i++) {
        if (i == indexPath.row) {
            if (flag == 1) {
                [self.flagDic setObject:@"0" forKey:[self.unitsArray  objectAtIndex:indexPath.row]];
            }else{
                [self.flagDic setObject:@"1" forKey:[self.unitsArray  objectAtIndex:indexPath.row]];
            }
        }else{
            [self.flagDic setObject:@"0" forKey:[self.unitsArray  objectAtIndex:i]];
        }
    }
}


#pragma mark
#pragma mark      图表
- (IBAction)showChartViewAction:(UIButton*)sender{
    
    NSString  *productIdPlus = @"plus";
    NSString  *productIdChart = @"chart";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL  is_buy = [[defaults  objectForKey:productIdPlus]  boolValue];
    BOOL  is_chart = [[defaults  objectForKey:productIdChart]  boolValue];
    
    if (is_buy || is_chart) {
        NSString  *currency = [self.unitsArray  objectAtIndex:self.indexPath.row];
        [Util  saveCurrencyForChartView:currency];
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];//这句话是防止手动先把设备置为竖屏,导致下面的语句失效.
    }else{
        
        UIAlertView  *alert = [[UIAlertView  alloc ] initWithTitle:LOCALIZATION(@"UpgradeAlert_Title") message:LOCALIZATION(@"UpgradeAlert_Message") delegate:self cancelButtonTitle:LOCALIZATION(@"UpgradeAlert_CancleButton") otherButtonTitles:LOCALIZATION(@"UpgradeAlert_SureButton"), nil];
        [alert  show];
        
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
//    if (buttonIndex == 1) {
//        AppPurcahseViewController  *appPurchase = [[AppPurcahseViewController  alloc ] initWithNibName:@"AppPurcahseViewController" bundle:nil];
//        self.navigationController.navigationBarHidden = NO;
//        [self.navigationController  pushViewController:appPurchase animated:YES];
//    }
}

#pragma mark
#pragma mark    汇率计算

- (void)calculateAllSelectedCurrcncyByInput:(NSString*)resultString{
    int   count = (int)self.unitsArray.count;
    for (int i = 0; i < count;i++) {
        NSString  *unitString = [self.unitsArray  objectAtIndex:i];
        NSString  *changesRate = [[Util  takeAllCountryInfor]  objectForKey:unitString];
        NSString  *selectedRate = [[Util  takeAllCountryInfor]   objectForKey:[self.unitsArray objectAtIndex:self.indexPath.row]];
        NSString  *result = nil;
        if (i != self.indexPath.row) {
            int   dataType  = [Util shareInstance].dataType;
            float  resultFloat = [resultString  doubleValue]/[selectedRate doubleValue]*[changesRate  doubleValue];
            result = [Util  roundUp:resultFloat afterPoint:dataType];
            [self.changesDic setObject:[Util   numberFormatterSetting:result withFractionDigits:dataType withInput:NO] forKey:unitString];
        }else{
            [self.changesDic setObject:[Util   numberFormatterSetting:resultString withFractionDigits:4 withInput:YES] forKey:unitString];
        }
    }
    
    [Util  saveChangeDic:self.changesDic];
}

#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    
    if (direction == MGSwipeDirectionLeftToRight) {
        return NO;
    }
    
    if (self.indexPath.row >= self.unitsArray.count) {
        return NO;
    }
    int  flag = [[self.flagDic  objectForKey:[self.unitsArray objectAtIndex:self.indexPath.row]]  intValue];
    if (flag == 0) {
        return YES;
    }
    return NO;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    __weak ChangesViewController_Pad * me = self;
    if (direction == MGSwipeDirectionLeftToRight) {
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 1.5;
    }
    else {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 2.0;
        CGFloat padding = 15.0;
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@""  icon:[UIImage imageNamed:@"删除@2x.png"]    backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            NSIndexPath * indexPath = [me.changeTable  indexPathForCell:sender];
            [me deleteChangesCell:indexPath];
            return YES;
        }];
        return @[trash];
    }
    return nil;
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive
{
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"SwippingLeftToRight"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"SwippingRightToLeft"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"ExpandingLeftToRight"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"ExpandingRightToLeft"; break;
    }
}

#pragma mark   添加国家
- (void)addCountryAction:(id)sender{
//    CountryViewController  *countryVC = [[CountryViewController alloc ] initWithNibName:@"CountryViewController" bundle:nil];
//    countryVC.delegate = self;
//    countryVC.selestedCountry = self.unitsArray;
//    [Util  saveSelectedCounrty:self.unitsArray];
//    [self preformTransitionToViewController:countryVC direction:kCATransitionFromTop withType:1];
}


#pragma amrk    长按 移动cell
- (void)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    CGPoint location = [longPress locationInView:self.changeTable];
    NSIndexPath *indexPath = [self.changeTable indexPathForRowAtPoint:location];
    
    for (NSString  *flag in self.flagDic.allValues) {
        if ([flag  intValue] == 1) {
            return;
        }
    }
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath && indexPath.row< self.unitsArray.count) {
                
                CGPoint locationBegan = [longPress locationInView:self.changeTable];
                NSIndexPath *indexPathBegan = [self.changeTable indexPathForRowAtPoint:locationBegan];
                stratIndexPath = indexPathBegan;
                
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.changeTable cellForRowAtIndexPath:indexPath];
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.changeTable addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    cell.hidden = YES;
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath] &&indexPath.row<self.unitsArray.count) {
                // ... update data source.
                [self.unitsArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                [Util saveSelectedCounrty:self.unitsArray];
                [self  saveSelectCountryForExtension:self.unitsArray];
                // ... move the rows.
                [self.changeTable moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.changeTable cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                
                if (sourceIndexPath.row == 0 || stratIndexPath.row == 0) {
                    [self  resetNumberUnderMove:nil];
                }
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                [self.changeTable  reloadData];
            }];
            break;
        }
    }
}

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}

- (void)swipeLeftAction:(UISwipeGestureRecognizer*)sender{
    ChangesCell  *cell = (ChangesCell*)sender.view;
    NSIndexPath  *index = [self.changeTable  indexPathForCell:cell];
    [self  deleteChangesCell:index];
}


#pragma   mark    ——————删除cell
-(void) deleteChangesCell:(NSIndexPath *) indexPath
{
    if (indexPath.row >= self.unitsArray.count) {
        return;
    }
    NSString  *cerrcuy = [self.unitsArray objectAtIndex:indexPath.row];
    [self.flagDic removeObjectForKey:cerrcuy];
    [self.changesDic  removeObjectForKey:cerrcuy];
    [self.unitsArray removeObject:cerrcuy];
    
    if (self.unitsArray.count!= 0) {
        [Util  saveSelectedCounrty:self.unitsArray];
        [self  saveSelectCountryForExtension:self.unitsArray];
    }
    if (self.changesDic.allKeys.count != 0) {
        [Util  saveChangeDic:self.changesDic];
    }
    
    [self.changeTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    self.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [Util  saveSelectedIndex:self.indexPath];
    
    if (indexPath.row == 0  && self.unitsArray.count!= 0) {
        [self   resetNumberUnderMove:nil];
    }
    
    [[NSNotificationCenter  defaultCenter]  postNotificationName:@"SelectedCountryChanged" object:nil];
    
    [[NSNotificationCenter  defaultCenter] postNotificationName:@"CurrencyChanged" object:nil userInfo:nil];
    
}

#pragma   mark     —————计算器
-(void) calculator_init{
    numbers = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".", nil];
    Operators = [[NSArray alloc] initWithObjects:@"+/−",@"%",@"÷",@"×",@"−",@"+",@"=", nil];
    Clears = [[NSArray alloc] initWithObjects:@"←",@"C",nil];
    display = [[NSMutableString alloc] initWithCapacity:40];
    resultNum = 0;
    leftNum = 0;
    rightNum = 0;
    isPlus = NO;
    isMinus= NO;
    isMultiply = NO;
    isDivide = NO;
    isleftNum = YES;
    isrightNum = NO;
    havePoint = NO;
    isOperate = NO;
    isAdd  = NO;
    lastOne = nil;
}

- (void) resetVariables:(NSIndexPath*)index{
    
    if (![index  isEqual:self.indexPath]) {
        ChangesCell *cell = (ChangesCell*)[self  tableView:self.changeTable cellForRowAtIndexPath:index];
        NSString  *value = cell.unitValueLable.text;
        if (isrightNum) {
            leftNum = [Util  numberFormatterForFloat:value];
            myTotal = [NSString  stringWithFormat:@"%.2f",[Util  numberFormatterForFloat:value]];
            if ([Util shareInstance].dataType == 0) {
                display = [NSMutableString  stringWithFormat:@"%d",(int)[Util  numberFormatterForFloat:value]];
            }else if ([Util shareInstance].dataType == 1){
                display = [NSMutableString  stringWithFormat:@"%.1f",[Util  numberFormatterForFloat:value]];
            }else{
                display = [NSMutableString  stringWithFormat:@"%.2f",[Util  numberFormatterForFloat:value]];
            }
            numDisplay = [Util  numberFormatterForFloat:value];
            rightNum = 0;
            isleftNum = YES;
            isrightNum  =NO;
            isPlus = NO;
            isMinus= NO;
            isMultiply = NO;
            isDivide = NO;
            isleftNum = NO;
            havePoint = NO;
            isOperate = NO;
        }else if (isleftNum){
            if (myTotal != nil) {
                havePoint = NO;
                leftNum = [Util  numberFormatterForFloat:value];
                numDisplay = [Util  numberFormatterForFloat:value];
                myTotal = [NSString  stringWithFormat:@"%.2f",[Util  numberFormatterForFloat:value]];
                rightNum = 0;
                if ([Util shareInstance].dataType == 0) {
                    display = [NSMutableString  stringWithFormat:@"%d",(int)[Util  numberFormatterForFloat:value]];
                }else if ([Util shareInstance].dataType == 1){
                    display = [NSMutableString  stringWithFormat:@"%.1f",[Util  numberFormatterForFloat:value]];
                }else{
                    display = [NSMutableString  stringWithFormat:@"%.2f",[Util  numberFormatterForFloat:value]];
                }
            }
        }else{
            havePoint = NO;
            leftNum = [Util  numberFormatterForFloat:value];
            myTotal =[NSString  stringWithFormat:@"%.2f",[Util  numberFormatterForFloat:value]];
            rightNum = 0;
            if ([Util shareInstance].dataType == 0) {
                display = [NSMutableString  stringWithFormat:@"%d",(int)[Util  numberFormatterForFloat:value]];
            }else if ([Util shareInstance].dataType == 1){
                display = [NSMutableString  stringWithFormat:@"%.1f",[Util  numberFormatterForFloat:value]];
            }else{
                display = [NSMutableString  stringWithFormat:@"%.2f",[Util  numberFormatterForFloat:value]];
            }
            numDisplay = [Util  numberFormatterForFloat:value];
        }
    }
}

-(void) calculator{
    if (isPlus) {
        numDisplay =leftNum +rightNum;
        int tmp = (int) numDisplay;
        if(tmp == numDisplay)
            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
        else
            myTotal = [[NSString alloc] initWithFormat:@"%.2f",numDisplay];
    }else if(isMinus){
        numDisplay =leftNum -rightNum;
        int tmp = (int) numDisplay;
        if(tmp == numDisplay)
            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
        else
            myTotal = [[NSString alloc] initWithFormat:@"%.2f",numDisplay];
    }else if(isMultiply){
        numDisplay =leftNum*rightNum;
        int tmp = (int) numDisplay;
        if(tmp == numDisplay)
            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
        else
            myTotal = [[NSString alloc] initWithFormat:@"%.2f",numDisplay];
    }else if(isDivide){
        numDisplay =leftNum/rightNum;
        int tmp = (int) numDisplay;
        if(tmp == numDisplay)
            myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
        else
            myTotal = [[NSString alloc] initWithFormat:@"%.2f",numDisplay];
    }
    self.changesResult = [NSString  stringWithString:myTotal];
    [self  calculateAllSelectedCurrcncyByInput:self.changesResult];
    [self.changeTable reloadData];
}


-(void) inputNum:(NSString *)str
{
    if([lastOne isEqual:@"0"]||[lastOne isEqual:@"1"]||[lastOne isEqual:@"2"]||[lastOne isEqual:@"3"]||[lastOne isEqual:@"4"]||[lastOne isEqual:@"5"]||[lastOne isEqual:@"6"]||[lastOne isEqual:@"7"]||[lastOne isEqual:@"8"]||[lastOne isEqual:@"9"]||[lastOne isEqual:@"."]){
        for (int i = 0; i < [numbers count]; i++) {
            if ([str isEqual:[numbers objectAtIndex:i]]) {
                if (havePoint&&[str isEqual: @"."]) {
                    break;
                }
                if([str isEqual:@"."]){
                    havePoint = YES;
                }
                if (display.length >9) {
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
                    leftNum = [display  doubleValue];
                    int tmp = (int) leftNum;
                    if(tmp == leftNum)
                        myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                    else
                        myTotal = [[NSString alloc] initWithFormat:@"%.4f",leftNum];
                }else{
                    isAdd = YES;
                    rightNum = [display  doubleValue];
                    int tmp = (int) rightNum;
                    if(tmp == rightNum)
                        myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                    else
                        myTotal = [[NSString alloc] initWithFormat:@"%.4f",rightNum];
                }
                break;
            }
        }
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
                    havePoint = YES;
                }
                else
                {
                    if (!isBackDelete) {
                        if (isleftNum) {
                            leftNum = [str  doubleValue];
                            int tmp = (int) leftNum;
                            if(tmp == leftNum)
                                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                            else
                                myTotal = [[NSString alloc] initWithFormat:@"%.4f",leftNum];
                        }else{
                            rightNum = [str  doubleValue];
                            int tmp = (int) rightNum;
                            if(tmp == rightNum)
                                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                            else
                                myTotal = [[NSString alloc] initWithFormat:@"%.4f",rightNum];
                        }
                    }else{
                        
                        if (display.length >9) {
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
                        if (isleftNum) {
                            leftNum = [display  doubleValue];
                            int tmp = (int) leftNum;
                            if(tmp == leftNum)
                                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
                            else
                                myTotal = [[NSString alloc] initWithFormat:@"%.4f",leftNum];
                        }else{
                            rightNum = [display  doubleValue];
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
                if (display.length >9) {
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
    if ([Util  isKeepingSound]) {
        AudioServicesPlaySystemSound(0x450);  //  系统自带按键声音
//        [self  playSoundsForButton]; //  播放自定义声音文件
    }
    
    if ([str  isEqualToString:self.localeSeparator]) {
        str = @".";
    }
    
    [self inputNum:str];
    if([str isEqual:@"+/−"]||[str isEqual:@"%"]||[str isEqual:@"÷"]||[str isEqual:@"×"]||[str isEqual:@"−"]||[str isEqual:@"+"]||[str isEqual:@"="]){
        if ([str isEqual:@"+/−"]) {
            numDisplay = -[myTotal  doubleValue];
            int tmp = (int) numDisplay;
            if(tmp == numDisplay)
                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
            else
                myTotal = [[NSString alloc] initWithFormat:@"%f",numDisplay];
        }else if([str isEqual:@"%"]){
            numDisplay = [myTotal  doubleValue]/100;
            int tmp = (int) numDisplay;
            if(tmp == numDisplay)
                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
            else
                myTotal = [[NSString alloc] initWithFormat:@"%f",numDisplay];
        }else if([str isEqual:@"÷"]){
            
            if(isOperate){
                int totle = (int)([myTotal doubleValue]*100);
                if (totle != 0) {
                    leftNum = numDisplay;
                }else{
                    leftNum = 0;
                }
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
                int totle = (int)([myTotal  floatValue]*100);
                if (totle != 0) {
                    leftNum = numDisplay;
                }else{
                    leftNum = 0;
                }
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
                int totle = (int)([myTotal  doubleValue]*100);
                if (totle != 0) {
                    leftNum = numDisplay;
                }else{
                    leftNum = 0;
                }
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
                int totle = (int)([myTotal doubleValue]*100);
                if (totle != 0) {
                    leftNum = numDisplay;
                }else{
                    leftNum = 0;
                }
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
            leftNum = [display  doubleValue];
            int tmp = (int) leftNum;
            if(tmp == leftNum)
                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
            else
                myTotal= display;
        }else{
            NSString *newDisplay = [display substringToIndex:[display length]-1];
            display =[[NSMutableString alloc] initWithFormat:@"%@",newDisplay];
            rightNum = [display  doubleValue];
            int tmp = (int) rightNum;
            if(tmp == rightNum)
                myTotal = [[NSString alloc] initWithFormat:@"%d",tmp];
            else
                myTotal = display;
        }
    }else if([str isEqual:@"C"]){
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
    if (myTotal != nil) {
        if (isrightNum == NO  && isleftNum == NO  &&isAdd) {
            leftNum = rightNum;
            rightNum = 0;
            isAdd = NO;
        }
        
        if ((int)([myTotal  doubleValue]*10000/100) == 0) {
            int  mytotal = [myTotal  intValue];
            self.changesResult = [NSString  stringWithFormat:@"%d",mytotal];
        }else{
            self.changesResult = [NSString  stringWithString:myTotal];
        }
        
        int  myTotol = (int)([myTotal  doubleValue] *100);
        if (myTotol ==0 ) {
            for (int i = 0; i<self.unitsArray.count; i++) {
                [self.changesDic  setObject:@"0" forKey:[self.unitsArray  objectAtIndex:i]];
            }
            [Util saveChangeDic:self.changesDic];
        }
        [self  calculateAllSelectedCurrcncyByInput:self.changesResult];
        [self.changeTable reloadData];
    }
}

#pragma mark - Listening for the user to trigger a refresh
-(IBAction)onClickButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self brain:button.titleLabel.text];
    [self addPopAnaitionClickButton:button];
    [self  shakeButton:button];
    
}


- (void)setCaculatorResult{
    int  myTotol = (int)([myTotal  doubleValue] *100);
    if (myTotol == 0) {
        leftNum = 0;
        rightNum = 0;
        numDisplay = 0;
        display = [NSMutableString stringWithString:@""];
        isOperate = NO;
        isMultiply = NO;
        isMinus = NO;
        isDivide = NO;
        isPlus = NO;
        isleftNum = YES;
        isrightNum = NO;
    }
}

- (void)shakeButton:(UIButton*)button
{
    [self.changeTable reloadData];
}


#pragma mark - Build MYBlurIntroductionView
- (void)firstLunch{
    
//    NSString *tutorialKey = [NSString stringWithFormat:@"%@_tutorial", NSStringFromClass ([self class])];
//    
//    BOOL wasShown = [[NSUserDefaults standardUserDefaults] boolForKey:tutorialKey];
//    
//    if (wasShown) {
//        return;
//    }
//    
//    [self startTapTutorialWithInfo:LOCALIZATION(@"TapMessage")
//                           atPoint:CGPointMake(IPHONE_WIDTH/2, IPHONE_HEIGHT/2)
//              withFingerprintPoint:CGPointMake(IPHONE_WIDTH - 50, 70)
//              shouldHideBackground:NO
//                        completion:^{
//                        }];
//    
//    int64_t delayInSeconds = 3;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
//        [self startCreateNewItemTutorialWithInfo:LOCALIZATION(@"PullDownMessage")];
//    });
//    
//    delayInSeconds = 7;
//    popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
//        [self  startTutorialWithInfo:LOCALIZATION(@"PullUpMessage") atPoint:CGPointMake(IPHONE_WIDTH/2, IPHONE_HEIGHT/2) withFingerprintStartingPoint:CGPointMake(IPHONE_WIDTH/2 , IPHONE_HEIGHT -100) andEndPoint:CGPointMake(IPHONE_WIDTH/2, IPHONE_HEIGHT/2 + 80) shouldHideBackground:NO completion:^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOCALIZATION(@"AlertViewTitle") message:LOCALIZATION(@"AlertViewMessage") delegate:nil cancelButtonTitle:LOCALIZATION(@"AlertViewCancleButton") otherButtonTitles:nil];
//            [alert show];
//        }];
//    });
}

- (NSString*)takeCurrencyInfoByName:(NSString*)currencyAbb{
    
    NSString  *currentLanguage = nil;
    NSString  *currencyName = nil;
    
    if ([[Localisator sharedInstance].currentLanguage  isEqualToString:@"zh-Hans"] || [[Localisator sharedInstance].currentLanguage  isEqualToString:@"zh-Hant"]) {
        currentLanguage = [[[Localisator sharedInstance].currentLanguage   componentsSeparatedByString:@"-"]  componentsJoinedByString:@""];
    }else{
        currentLanguage = [Localisator sharedInstance].currentLanguage;
    }
    
    currencyName = [[self.currencyDic   objectForKey:currencyAbb]  objectForKey:currentLanguage];
    return currencyName;
}

- (void)takeCurrencyInfroDic{
    
    NSMutableDictionary  *tempDic = [NSMutableDictionary  dictionary];
    for (NSDictionary   *currencyDic  in [Util   readQuestionData]) {
        NSString  *abb = [currencyDic  objectForKey:@"currencyAbbreviated"];
        [tempDic  setValue:currencyDic forKey:abb];
    }
    self.currencyDic = tempDic;
}


- (void)playSoundsForButton{
    SystemSoundID  sameViewSoundID;
    NSString *thesoundFilePath = [[NSBundle mainBundle] pathForResource:@"Clapping Crowd Studio 01" ofType:@"caf"];    //创建音乐文件路径
    CFURLRef  thesoundURL = (__bridge CFURLRef) [NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &sameViewSoundID);
    //变量SoundID与URL对应
    AudioServicesPlaySystemSound(sameViewSoundID);  //播放SoundID声音
}

#pragma mark
#pragma mark       UIBackgroundFetch
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
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
//                    [self.changeTable  saveRequestDate:[Util  changeDateToStringWith:[NSDate  date]]];
                    self.rateDic = [Util  deaWithRequestData:[dataDic  objectForKey:@"list"]];
                    [Util saveTextByNSUserDefaults:self.rateDic];
                    [Util  saveAllCountryInfor:self.rateDic];
                    completionHandler(UIBackgroundFetchResultNewData);
                });
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    completionHandler(UIBackgroundFetchResultFailed);
                });
            }
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                completionHandler(UIBackgroundFetchResultFailed);
            });
        }
    });
}

- (void)handleWatchKitExtension:(NSNotification*)notification{
    
    NSDictionary  *userInfor = notification.object;
    
    if ([[userInfor  objectForKey:@"infor"]  isEqualToString:@"request"]) {
        [self  ratesAndCountryRequest];
    }else{
        [self  resetNumberUnderMove:nil];
        [self.changeTable   reloadData];
    }
}


- (void)addPopAnaitionClickButton:(UIButton*)button{
    
    if (button.tag == 2024) {
        [button setTitle:self.localeSeparator forState:UIControlStateNormal];
    }
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addCurrency"])
    {
        CurrencyController  *customViewController = segue.destinationViewController;
        customViewController.delegate = self;
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
