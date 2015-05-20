//
//  AppDelegate.m
//  UnitsChanges
//
//  Created by zhangmeng on 14/10/24.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import "AppDelegate.h"
#import "ChangesViewController.h"
#import "iRate.h"
#import "MobClick.h"
#import "Localisator.h"
#import "Util.h"

#import "SimpleChangesViewController.h"

#import "ChangesViewController_Pad.h"
#import "SplitDetailViweController.h"
#import "SettingViewController_Pad.h"

#define  UMENG_APPKEY  @"54d96f3dfd98c5b7760008da"
@interface AppDelegate ()<iRateDelegate,UIAlertViewDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic,retain) UINavigationController  *nv;
@property (nonatomic,retain) SimpleChangesViewController *simpleVc;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 友盟
    [self umengTrack];
    [self  takeLocaleLanguage];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;

        splitViewController.maximumPrimaryColumnWidth = 400; // 调整SplitViewController分割的宽度
        
        UINavigationController *detailNavigationController = [splitViewController.viewControllers objectAtIndex:1];
        detailNavigationController.navigationBar.barTintColor = [UIColor  whiteColor];
        
        SplitDetailViweController *detailViewController = [detailNavigationController.viewControllers firstObject];
        
        UINavigationController *masterNavigationController = [splitViewController.viewControllers firstObject];
        masterNavigationController.navigationBar.barTintColor = [UIColor  whiteColor];
        ChangesViewController_Pad *masterViewController = [masterNavigationController.viewControllers firstObject];
        masterViewController.detailViewController = detailViewController;

    }else{
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        //   fetch background
        [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        //  摇一摇
        [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.nv = [[UINavigationController alloc ] initWithRootViewController:[storyboard instantiateInitialViewController]];
        self.nv.navigationBarHidden= YES;
        
        self.simpleVc = [[SimpleChangesViewController alloc ] initWithNibName:@"SimpleChangesViewController" bundle:nil];
        
        self.pageViewController = [[CustomPageViewController  alloc ] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        [self.pageViewController  setViewControllers:@[self.nv] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        self.pageViewController.delegate = self;
        self.pageViewController.dataSource = self;
        
        [self.window setRootViewController:self.pageViewController];
        self.window.backgroundColor = [UIColor whiteColor];
         [self.window makeKeyAndVisible];

    }
    
    return YES;
}

#pragma  mark 
#pragma  mark    UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(CustomPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    if (viewController == self.nv) {
        return self.simpleVc;
    }else{
         return nil;
    }
   }

- (UIViewController *)pageViewController:(CustomPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    if (viewController == self.simpleVc) {
        return self.nv;
    }
    else{
        return nil;
    }
   }


#pragma mark
#pragma mark   UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (NO == self.pageViewController.isPageToBounce) {
        if (self.pageViewController.pageIndex == 0 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        }
        
        if (self.pageViewController.pageIndex == [self.pageViewController.viewControllersArray count]-1 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
   
    if (NO == self.pageViewController.isPageToBounce) {
        if (self.pageViewController.pageIndex == 0 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
            velocity = CGPointZero;
            *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        }
        if (self.pageViewController.pageIndex == [self.pageViewController.viewControllersArray count]-1 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
            velocity = CGPointZero;
            *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        }
    }
    
}

#pragma mark
#pragma mark    语言
- (void)takeLocaleLanguage{
   
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([[Localisator  sharedInstance].currentLanguage  isEqualToString:@"DeviceLanguage"]) {
        if (![[Localisator sharedInstance].availableLanguagesArray  containsObject:currentLanguage]) {
               currentLanguage = @"en";
        }
           [[Localisator  sharedInstance]  setLanguage:currentLanguage];
          [[Localisator  sharedInstance]  setSaveInUserDefaults:YES];
    }
}

//  评论  iRate
+ (void)initialize
{
    [iRate sharedInstance].applicationBundleID = @"com.xadavetech.currencychanger";
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    [iRate sharedInstance].daysUntilPrompt = 1;
    [iRate sharedInstance].usesUntilPrompt = 5;
    [iRate sharedInstance].remindPeriod = 3;
    //enable preview mode
    [iRate sharedInstance].previewMode = NO;
}

- (BOOL)iRateShouldPromptForRating
{
    if (!self.alertView)
    {
        self.alertView = [[UIAlertView alloc] initWithTitle:LOCALIZATION(@"iRateMessageTitle") message:LOCALIZATION(@"iRateAppMessage")  delegate:self cancelButtonTitle:LOCALIZATION(@"iRateCancelButton") otherButtonTitles:LOCALIZATION(@"iRateRateButton"),LOCALIZATION(@"iRateRemindButton"), nil];
        
        [self.alertView show];
    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        //ignore this version
        [iRate sharedInstance].declinedThisVersion = YES;
    }
    else if (buttonIndex == 1) // rate now
    {
        //mark as rated
        [iRate sharedInstance].ratedThisVersion = YES;
        //launch app store
        [[iRate sharedInstance] openRatingsPageInAppStore];
    }
    else if (buttonIndex == 2) // maybe later
    {
        //remind later
        [iRate sharedInstance].lastReminded = [NSDate date];
    }
    else if (buttonIndex == 3) // open web page
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apple.com"]];
    }
    self.alertView = nil;
}

#pragma mark
#pragma  mark    友盟
- (void)umengTrack {
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //      [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}


- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}


-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSDate *fetchStart = [NSDate date];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChangesViewController *viewController = (ChangesViewController *)[storyboard instantiateInitialViewController];
    [viewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
        NSDate *fetchEnd = [NSDate date];
        NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
        NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
    }];
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        if (self.allowRotation) {
            return UIInterfaceOrientationMaskPortrait |UIInterfaceOrientationMaskLandscape;
        }
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

- (NSUInteger)supportedInterfaceOrientations

{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskPortrait |UIInterfaceOrientationMaskLandscape;
    }
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    }else{
        return UIInterfaceOrientationPortrait;
    }
}


- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply{
    
    if ([[userInfo  objectForKey:@"infor" ]  isEqualToString:@"request"]) {
        
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
                        
                         reply(@{@"appData":[Util  deaWithRequestData:[dataDic  objectForKey:@"list"]]});
                        [Util  saveRequestDate:[Util  changeDateToStringWith:[NSDate  date]]];
                        [Util saveTextByNSUserDefaults:[Util  deaWithRequestData:[dataDic  objectForKey:@"list"]]];
                        [Util  saveAllCountryInfor:[Util  deaWithRequestData:[dataDic  objectForKey:@"list"]]];
                });
                }
            }
        });
    }else{
        reply(@{@"TextInput":@"app has received inputText"});
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
