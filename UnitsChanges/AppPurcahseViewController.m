//
//  AppPurcahseViewController.m
//  Currenci
//
//  Created by Aries on 15/3/4.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "AppPurcahseViewController.h"
#import "Util.h"
#import "AppPurchaseCell.h"
#import "Localisator.h"
#import "AppDelegate.h"

@interface AppPurcahseViewController ()<ASBankerDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *appPurchaseTable;
@property (nonatomic,retain)  NSString  *timeString;

@end

@implementation AppPurcahseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.banker = [ASBanker sharedInstance];
    if (self.banker) {
        self.banker.delegate = self;
    }
    if (!self.products) {
        [self.banker fetchProducts:@[@"plus",@"chart"]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    self.timeString = [NSString stringWithFormat:@"2018-01-01"];

    // pageViewController
    AppDelegate  *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (UIScrollView   *scrollView  in  delegate.pageViewController.view.subviews ) {
        scrollView.scrollEnabled = NO;
    }

    self.appPurchaseTable.contentSize = CGSizeMake(self.appPurchaseTable.frame.size.width, 380);
    [self  takeScheduledTimeRequest];
    [self drawNav];
}

- (void)drawNav{
    
    UIButton  *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardButton.frame = CGRectMake(0, 0, 12, 20);
    [forwardButton  setBackgroundImage:[[UIImage imageNamed:@"forward.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //  UIImageRenderingMode   设置tintColor 时,图片的颜色可以根据此属性随设置的tintColor改变
    
    [forwardButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem   *leftItem = [[UIBarButtonItem  alloc ]  initWithCustomView:forwardButton];
     [self.navigationItem  setLeftBarButtonItem:leftItem animated:YES];
    
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 0, 80, 30);
    [button  setTitle:LOCALIZATION(@"RestorePurchases") forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont   fontWithName:@"HelveticaNeue" size:18.0]];
    [button setTitleColor:[Util  shareInstance].themeColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(restoreAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem   *rightItem = [[UIBarButtonItem  alloc ]  initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [Util  shareInstance].themeColor;
    
    self.title = LOCALIZATION(@"Upgrade");
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,[UIFont  fontWithName:@"HelveticaNeue-Light" size:20],NSFontAttributeName,nil]];

}

- (void)backAction:(UIButton*)sender{
    
    NSString  *productIdPlus = @"plus";
    NSString  *productIdChart = @"chart";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL  is_buy = [[defaults  objectForKey:productIdPlus]  boolValue];
    BOOL  is_chart = [[defaults  objectForKey:productIdChart]  boolValue];
    
    if (is_chart || is_buy) {
         [self.navigationController  popViewControllerAnimated:YES];
    }else{
        BOOL    isExpire = [Util takeTimeDifference:self.timeString];
        if (isExpire) {
            UIAlertView  *alertView = [[UIAlertView alloc ] initWithTitle:LOCALIZATION(@"AppPurchaseFreeAlert_Title") message:LOCALIZATION(@"AppPurchaseFreeAlert_Message") delegate:self cancelButtonTitle:nil otherButtonTitles:LOCALIZATION(@"AppPurchaseFreeAlert_RateButton"),LOCALIZATION(@"AppPurchaseFreeAlert_CancleButton"), nil];
            alertView.cancelButtonIndex = 1;
            [alertView show];
        }else{
            [self.navigationController  popViewControllerAnimated:YES];
        }
    }
}


- (void)restoreAction:(UIButton*)sender{
    [self.banker   restorePurchases];
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
#pragma amrk   UITableViewDataSource,UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

     static    NSString * identifier = @"AppPurchaseCell";
    AppPurchaseCell  *cell = [tableView  dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle  mainBundle]  loadNibNamed:@"AppPurchaseCell" owner:self options:nil]  objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    SKProduct  *skProduct = [self.products  objectAtIndex:indexPath.row];
    
    NSLog(@"%@\n%@\n%@",[skProduct  localizedTitle],[skProduct  localizedPrice],[skProduct  localizedDescription]);

    if (indexPath.row == 1) {
        cell.appPurchaseLogo.image = [UIImage  imageNamed:@"赞助.png"];
        cell.productNameLable.text = LOCALIZATION(@"UpgradePlusVersion");
        NSString  *description1 = LOCALIZATION(@"UpgradePlusVersion_description_1");
        NSString  *descriptionString =  [NSString  stringWithFormat:@"%@",description1];
         CGSize   size = [descriptionString  boundingRectWithSize:CGSizeMake(255, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.descriptionLable.font} context:nil].size;
          cell.descriptionLable.frame = CGRectMake(cell.descriptionLable.frame.origin.x, cell.descriptionLable.frame.origin.y, 255, size.height);
         cell.descriptionLable.text = descriptionString;

    }else if (indexPath.row == 0){
        
        cell.appPurchaseLogo.image = [UIImage imageNamed:@"pro.png"];
        cell.productNameLable.text = LOCALIZATION(@"UnlockHistoricalChart");
        NSString  *description1 = LOCALIZATION(@"UnlockHistoricalChart_description");
        cell.descriptionLable.text = description1;
    }
    
    cell.priceLable.text = [skProduct  localizedPrice];
    cell.priceLable.textColor = [Util  shareInstance].themeColor;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SKProduct  *product = [self.products  objectAtIndex:indexPath.row];
    [self appPurchaseAction:product];
}


- (void)appPurchaseAction:(SKProduct*)product {
    [self.banker   purchaseItem:product];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];;
}

- (void)somthingWentWrong {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:LOCALIZATION(@"AppPurchaseAlert_Title")
                                                 message:LOCALIZATION(@"AppPurchaseAlert_Message")
                                                delegate:nil
                                       cancelButtonTitle:LOCALIZATION(@"AppPurchaseAlert_CancleButton")
                                       otherButtonTitles:nil];
    [av show];
}

#pragma mark
#pragma mark    ASBankerDelegate
- (void)bankerFailedToConnect {
    [self somthingWentWrong];
}

- (void)bankerNoProductsFound {
    [self somthingWentWrong];
}

- (void)bankerFoundProducts:(NSArray *)products {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (self.products) {
        self.products = nil;
    }
    self.products = [NSMutableArray arrayWithArray:products];
    
    [self.appPurchaseTable  reloadData];
}

- (void)bankerFoundInvalidProducts:(NSArray *)products {
    [self somthingWentWrong];
}

- (void)bankerProvideContent:(SKPaymentTransaction *)paymentTransaction {
    // Unlock feature or content here for the user.
    for (SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:paymentTransaction.payment.productIdentifier]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:product.productIdentifier];
            [defaults synchronize];
            [Util  saveAppPurchaseStateWithProductID:product.productIdentifier];
        }
    }
}


- (void)bankerPurchaseComplete:(SKPaymentTransaction *)paymentTransaction {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:LOCALIZATION(@"AppPurchaseCompleteAlert_Title")
                                                 message:LOCALIZATION(@"AppPurchaseCompleteAlert_Message")
                                                delegate:nil
                                       cancelButtonTitle:LOCALIZATION(@"AppPurchaseCompleteAlert_CancleButton")
                                       otherButtonTitles:nil];
    [av show];
    
}

- (void)bankerPurchaseFailed:(NSString *)productIdentifier withError:(NSString *)errorDescription {
    [self somthingWentWrong];
}


- (void)bankerPurchaseCancelledByUser:(NSString *)productIdentifier {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    BOOL    isExpire = [Util takeTimeDifference:self.timeString];
    if (isExpire) {
        UIAlertView  *alertView = [[UIAlertView alloc ] initWithTitle:LOCALIZATION(@"AppPurchaseFreeAlert_Title") message:LOCALIZATION(@"AppPurchaseFreeAlert_Message") delegate:self cancelButtonTitle:nil otherButtonTitles:LOCALIZATION(@"AppPurchaseFreeAlert_RateButton"),LOCALIZATION(@"AppPurchaseFreeAlert_CancleButton"), nil];
        alertView.cancelButtonIndex = 1;
        [alertView show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSString *str = [NSString stringWithFormat:
                         @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=946607423&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

        for (SKProduct *product in self.products) {
            [Util  saveAppPurchaseStateWithProductID:product.productIdentifier];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:product.productIdentifier];
            [defaults synchronize];
        }
    }else{
        [self.navigationController  popViewControllerAnimated:YES];
    }
}

- (void)bankerFailedRestorePurchases {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

// Optional
- (void)bankerDidRestorePurchases {
}

- (void)bankerCanNotMakePurchases {
    // In-App Purchase are probally disabled in the Settings
    // Tell the user
}

- (void)bankerContentDownloadComplete:(SKDownload *)download {}
- (void)bankerContentDownloading:(SKDownload *)download {}


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
