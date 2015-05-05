//
//  SimpleChangesViewController.m
//  Currenci
//
//  Created by Aries on 15/3/31.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "SimpleChangesViewController.h"
#import "AppDelegate.h"
#import "Util.h"
#import "BaseCurrencyCell.h"

@interface SimpleChangesViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property  (nonatomic,retain)  NSMutableArray  *simpleArray;
@property (nonatomic,retain) NSMutableDictionary  *currencyInfor;
@property (nonatomic,retain)  NSMutableDictionary  *resultDic;

@property (nonatomic,retain) NSMutableString  *textFieldText;

@property (weak, nonatomic) IBOutlet UITableView *baseTableView;
@property (weak, nonatomic) IBOutlet UIView *baseView;

@property (weak, nonatomic) IBOutlet UILabel *baseLbale;

@property (weak, nonatomic) IBOutlet UILabel *targetLable;

@property (weak, nonatomic) IBOutlet UITextField *baseValueInPut;

@property (weak, nonatomic) IBOutlet UILabel *targetCurrency;


@end

@implementation SimpleChangesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.simpleArray = [NSMutableArray  arrayWithArray:[Util  takeSelectedCountry]];
    self.currencyInfor = [self  takeCurrencyInfor];
     [self  initializationBaseCurrenciInfor];
    [self  calculateValueUnderBaseCurrency];
    
    self.textFieldText = [NSMutableString  stringWithFormat:@"%d",(int)[Util  numberFormatterForFloat:self.baseValueInPut.text]];
    
    [[NSNotificationCenter  defaultCenter]  addObserver:self selector:@selector(selectedCountryChanged:) name:@"SelectedCountryChanged" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    AppDelegate  *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.allowRotation = NO;
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


- (void)initializationBaseCurrenciInfor{
    
    self.baseView.backgroundColor = [Util  shareInstance].themeColor;
    self.baseValueInPut.text = [Util  readDefaultValue];
    self.targetCurrency.text = [self.simpleArray  objectAtIndex:0];
    self.baseValueInPut.keyboardType = UIKeyboardTypeNumberPad;
    self.baseValueInPut.inputAccessoryView = [self  createToolbar];
    
    self.baseLbale.text = LOCALIZATION(@"ReferenceValue");
    self.targetLable.text = LOCALIZATION(@"TargetCurrency");
}

- (void)selectedCountryChanged:(NSNotification*)notification{
    self.simpleArray = [NSMutableArray  arrayWithArray:[Util  takeSelectedCountry]];
    self.currencyInfor = [self  takeCurrencyInfor];
    [self  initializationBaseCurrenciInfor];
    [self  calculateValueUnderBaseCurrency];

}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.simpleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static   NSString* identifier = @"SimpleCell";
    BaseCurrencyCell  *cell = [tableView  dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]  loadNibNamed:@"BaseCurrencyCell" owner:self options:nil]  objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString  *currentLanguage = nil;

    NSString  *country = [self.simpleArray  objectAtIndex:indexPath.row];
    NSDictionary  *countryDic = [self.currencyInfor  objectForKey:country];

    if ([[Localisator sharedInstance].currentLanguage  isEqualToString:@"zh-Hans"] || [[Localisator sharedInstance].currentLanguage  isEqualToString:@"zh-Hant"]) {
        currentLanguage = [[[Localisator sharedInstance].currentLanguage   componentsSeparatedByString:@"-"]  componentsJoinedByString:@""];
    }else{
        currentLanguage = [Localisator sharedInstance].currentLanguage;
    }
    
    if ([self.targetCurrency.text  isEqualToString:country]) {
        cell.stateFlage.backgroundColor = [Util  shareInstance].themeColor;
    }else{
        cell.stateFlage.backgroundColor = [UIColor  clearColor];
    }
    
    cell.baseValueLable.text = self.baseValueInPut.text;
    cell.baseValueLable.adjustsFontSizeToFitWidth = YES;
    cell.targetValueLable.text = [self.resultDic  objectForKey:country];
    cell.targetValueLable.adjustsFontSizeToFitWidth = YES;
    
    cell.targetCurrencyName.text = [[self.currencyInfor  objectForKey:self.targetCurrency.text]  objectForKey:currentLanguage];

    cell.currencyNameLable.text = [countryDic  objectForKey:currentLanguage];
    cell.countryFlag.image = [UIImage  imageNamed:[NSString stringWithFormat:@"%@.png",country]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.targetCurrency.text = [self.simpleArray  objectAtIndex:indexPath.row];
    [self  calculateValueUnderBaseCurrency];
}


#pragma mark 
#pragma mark   UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (![string isEqualToString:@""]) {
        if (self.textFieldText.length <=9) {
              [self.textFieldText  appendString:string];
        }
    }else{
        
        if (self.textFieldText.length>=1) {
             [self.textFieldText deleteCharactersInRange:NSMakeRange(self.textFieldText.length - 1, 1)];
        }
    }
    
     textField.text = [Util  numberFormatterSetting:[NSString  stringWithFormat:@"%f",[Util numberFormatterForFloat:self.textFieldText]] withFractionDigits:2 withInput:YES];
     [self calculateValueUnderBaseCurrency];
    
    return NO;
}


#pragma mark
#pragma mark   ToolBar
-(UIToolbar*) createToolbar {
    
    CGFloat   height = 34;
    if (iPhone6plus) {
        height = 42;
    }

    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    toolBar.clipsToBounds = YES;
    toolBar.barTintColor = [Util   colorWithHexString:@"#d2d6db"];
    toolBar.tintColor = [Util  shareInstance].themeColor;
    toolBar.barStyle = UIBarStyleDefault;

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldDone)];
    toolBar.items = @[space, done];
    
    return toolBar;
}

- (void)textFieldDone{
    
    if (self.baseValueInPut.text.length != 0) {
            self.baseValueInPut.text = [Util  numberFormatterSetting:[NSString  stringWithFormat:@"%f",[Util numberFormatterForFloat:self.textFieldText]] withFractionDigits:2 withInput:YES];
    }else{
        self.baseValueInPut.text = [Util readDefaultValue];
    }
    [self.baseValueInPut  resignFirstResponder];
}

#pragma mark
#pragma mark   汇率计算

- (void)calculateValueUnderBaseCurrency{

    NSMutableDictionary  *valueDic = [NSMutableDictionary  dictionary];
    NSDictionary  *rateDic = [Util   takeAllCountryInfor];
    NSString *baseRate = [rateDic  objectForKey:self.targetCurrency.text];
    
    for (int i = 0; i < self.simpleArray.count; i++) {
        NSString *unitString = [self.simpleArray   objectAtIndex:i];
        NSString  *   currentRate = [rateDic  objectForKey:unitString];
        int   dataType  = [Util shareInstance].dataType;
        float  resultFloat = [Util  numberFormatterForFloat:self.baseValueInPut.text]/[currentRate doubleValue]*[baseRate  doubleValue];
        NSString  *result = [Util  roundUp:resultFloat afterPoint:dataType];
        [valueDic setObject:[Util   numberFormatterSetting:result withFractionDigits:dataType withInput:NO] forKey:unitString];
    }
    
    self.resultDic = valueDic;
    [self.baseTableView  reloadData];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
