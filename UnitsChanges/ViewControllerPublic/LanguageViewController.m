//
//  LanguageViewController.m
//  Currenci
//
//  Created by Aries on 15/2/27.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanguageCell.h"
#import "DecimalsCell.h"
#import "Util.h"
#import "Localisator.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "AppPurcahseViewController.h"

@interface LanguageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *languageTable;

@property (nonatomic,retain)  NSMutableArray  *languageArray;
@property (nonatomic,retain) NSMutableDictionary  *languageDic;

@property (nonatomic,retain) NSIndexPath *indexPath;

@property (nonatomic,retain)  NSString  *timeString;

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self  drawNav];
    
    self.indexPath= [NSIndexPath  indexPathForRow:0 inSection:0];
    
    if (self.isLanguage) {
        self.languageArray = [NSMutableArray   arrayWithObjects:@"English",@"简体中文",@"繁體中文",@"日本语",@"Español",@"Deutsch",@"Français",@"Português", nil];
        self.languageDic = [NSMutableDictionary  dictionaryWithObjectsAndKeys:@"en",@"English",@"zh-Hans",@"简体中文",@"zh-Hant",@"繁體中文",@"ja",@"日本语",@"es",@"Español",@"de",@"Deutsch",@"fr",@"Français",@"pt",@"Português", nil];
        self.title = LOCALIZATION(@"LanguageVCTitle");
    }else{
        self.title = LOCALIZATION(@"number");
        self.timeString = [NSString stringWithFormat:@"2018-01-01"];
        [self  takeScheduledTimeRequest];
    }
    
     [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,[UIFont  fontWithName:@"HelveticaNeue-Light" size:20],NSFontAttributeName,nil]];
    
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
        [self.languageTable  saveColorString:theme];
        [Util  saveColorByNSUserDefaults:theme];
        
        self.navigationController.navigationBar.tintColor = [Util shareInstance].themeColor;
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,[UIFont  fontWithName:@"HelveticaNeue-Light" size:20],NSFontAttributeName,nil]];
    }
}


- (void)drawNav{

    UIButton  *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardButton.frame = CGRectMake(0, 0, 12, 20);
    [forwardButton  setBackgroundImage:[[UIImage imageNamed:@"forward.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //  UIImageRenderingMode   设置tintColor 时,图片的颜色可以根据此属性随设置的tintColor改变
    
    [forwardButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem   *leftItem = [[UIBarButtonItem  alloc ]  initWithCustomView:forwardButton];

    [self.navigationItem setLeftBarButtonItem:leftItem animated:YES];
    
     [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,[UIFont  fontWithName:@"HelveticaNeue-Light" size:20],NSFontAttributeName,nil]];
    
    self.navigationController.navigationBar.tintColor = [Util  shareInstance].themeColor;
}

- (void)backAction:(UIButton*)sender{
    [self.navigationController  popViewControllerAnimated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.isLanguage) {
         return self.languageArray.count;
    }
    return 5;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.isLanguage) {
        static   NSString  *idString = @"LanuageCell";
        LanguageCell  *cell = [tableView  dequeueReusableCellWithIdentifier:idString];
        if (cell == nil) {
            cell = [[[NSBundle  mainBundle ]  loadNibNamed:@"LanguageCell" owner:self options:nil]  objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSString  *language = [Localisator sharedInstance].currentLanguage;
        if ([language  isEqualToString:[self.languageDic  objectForKey:[self.languageArray objectAtIndex:indexPath.row]]]) {
            cell.backView.backgroundColor = [UIColor  colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
        }
        cell.languageNameLable.text = [self.languageArray  objectAtIndex:indexPath.row];
        return cell;
    }else{
        static   NSString  *idString = @"DecimailsCell";
        DecimalsCell  *cell = [tableView  dequeueReusableCellWithIdentifier:idString];
        if (cell == nil) {
            cell = [[[NSBundle  mainBundle ]  loadNibNamed:@"DecimalsCell" owner:self options:nil]  objectAtIndex:0];
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if ([Util  takeDataType] == indexPath.row) {
            cell.backView.backgroundColor = [UIColor  colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
        }
        
        switch (indexPath.row) {
            case 0:
                cell.nameLable.text = LOCALIZATION(@"Integer");
                cell.valueLable.text = @"0";
                break;
            case 1:
                cell.nameLable.text = LOCALIZATION(@"Decimals_One");
                cell.valueLable.text = @"0.0";
                break;
            case 2:
                cell.nameLable.text = LOCALIZATION(@"Decimals_Two");
                cell.valueLable.text = @"0.00";
                break;
            case 3:
                cell.nameLable.text = LOCALIZATION(@"Decimals_Three");
                cell.valueLable.text = @"0.000";
                break;
            case 4:
                cell.nameLable.text = LOCALIZATION(@"Decimals_Four");
                cell.valueLable.text = @"0.0000";
                break;
                
            default:
                break;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.indexPath = indexPath;
    if (self.isLanguage) {
        NSString  *language = [self.languageDic  objectForKey:[self.languageArray objectAtIndex:indexPath.row]];
        [[Localisator  sharedInstance]  setLanguage:language];
        [[Localisator sharedInstance]  setSaveInUserDefaults:YES];
        self.title = LOCALIZATION(@"LanguageVCTitle");
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            [[NSNotificationCenter  defaultCenter]  postNotificationName:@"LanguageChanged" object:nil];
        }
        [self.navigationController  popViewControllerAnimated:YES];
    }else{
        NSString  *productIdPlus = @"plus";
        NSString  *productIdChart = @"chart";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL  is_buy = [[defaults  objectForKey:productIdPlus]  boolValue];
        BOOL  is_chart = [[defaults  objectForKey:productIdChart]  boolValue];
        
        if ((indexPath.row == 3 || indexPath.row == 4) &&  !is_buy && !is_chart) {
            UIAlertView  *alert = [[UIAlertView  alloc ] initWithTitle:LOCALIZATION(@"UpgradeAlert_Title") message:LOCALIZATION(@"UpgradeAlert_Message") delegate:self cancelButtonTitle:LOCALIZATION(@"UpgradeAlert_CancleButton") otherButtonTitles:LOCALIZATION(@"UpgradeAlert_SureButton"), nil];
            [alert  show];
        }else{
            [Util  saveDataType:(int)indexPath.row :YES];
            [Util shareInstance].dataType =(int) indexPath.row;
            [Util  saveDataTypeByNSUserDefaults:[NSString  stringWithFormat:@"%d",(int)indexPath.row] :YES];
            [self.navigationController  popViewControllerAnimated:YES];
        }
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
