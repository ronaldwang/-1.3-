//
//  CountryViewController.m
//  UnitsChanges
//
//  Created by zhangmeng on 14/11/6.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import "CountryViewController.h"
#import "UnitsCell.h"
#import "Util.h"
#import "ChangesViewController.h"
#import "PullHeaderView.h"
#import "SettingViewController.h"
#import "MGSwipeButton.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "AppDelegate.h"
#import "UIViewController+Tutorial.h"

@interface CountryViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,PullHeaderDelegate,MGSwipeTableCellDelegate,UIScrollViewDelegate>{
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *countryTable;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (assign,nonatomic)  BOOL  isSearch;

@property (nonatomic,strong) NSMutableArray *filterArray;
@property (nonatomic,strong) NSMutableArray *resultArray;
@property (nonatomic,strong) NSMutableArray *collectArray;

@property(nonatomic) PullHeaderView *prevPullHeaderView;
@property BOOL isLoading;

@end

@implementation CountryViewController

- (IBAction)settingAction:(id)sender {
    
    SettingViewController  *settingVC = [[SettingViewController alloc ] initWithNibName:@"SettingViewController" bundle:nil];
    
    UINavigationController *nv = [[UINavigationController alloc ] initWithRootViewController:settingVC];
    
    [nv.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,nil]];   //  IOS7 之前 用 UITextAttributeTextColor
    [self presentViewController:nv animated:YES completion:^{
    }];
    
//    [self.navigationController  pushViewController:settingVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;   //  取消Scrollview及其子类 在视图控制器上部的留白(默认为Yes)
    self.filterArray = [NSMutableArray array];
    self.resultArray = [NSMutableArray  array];
    
    if ([Util  takeCollectCountry].count != 0) {
        self.collectArray = [NSMutableArray  arrayWithArray:[Util takeCollectCountry]];
    }else{
        self.allCountry = [NSMutableArray  arrayWithArray:[Util   readQuestionData]];
        [self  takeDefaultCollectCountry];
    }
    
   [self  takeOutCollectCountryFromAll];
    
    [self.settingButton  setBackgroundImage:[[UIImage imageNamed:@"设置.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [self   customerTutorial];
    
    //  摇一摇
    [self becomeFirstResponder];
    
    // pageViewController
     AppDelegate  *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (UIScrollView   *scrollView  in  delegate.pageViewController.view.subviews ) {
        scrollView.scrollEnabled = NO;
    }
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
        [self.countryTable  saveColorString:theme];
         [Util  saveColorByNSUserDefaults:theme];
         self.searchBar.tintColor = [Util shareInstance].themeColor;
        [self.settingButton  setTintColor:[Util shareInstance].themeColor];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super  viewWillAppear:animated];
    AppDelegate  *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.allowRotation = NO;
    self.navigationController.navigationBarHidden = YES;
    self.searchBar.placeholder = LOCALIZATION(@"search");
    self.searchBar.tintColor = [Util shareInstance].themeColor;
    [self.countryTable  reloadData];
    if (_prevPullHeaderView == nil) {
        PullHeaderView *view = [[PullHeaderView alloc] initWithScrollView:self.countryTable arrowImageName:@"blackArrow.png" textColor:[UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0] subText:@"prev article" position:PullHeaderTop];
        view.delegate = self;
        [self.countryTable addSubview:view];
        _prevPullHeaderView = view;
    }
    [_prevPullHeaderView updateSubtext];
    [self.settingButton  setTintColor:[Util shareInstance].themeColor];
    
}

- (void)customerTutorial{
    [self startTapTutorialWithInfo:LOCALIZATION(@"TapMessageForSetting")
                           atPoint:CGPointMake(IPHONE_WIDTH/2, IPHONE_HEIGHT/2)
              withFingerprintPoint:CGPointMake(IPHONE_WIDTH - 30, 40)
              shouldHideBackground:NO
                        completion:^{
                        }];
}

#pragma mark  
#pragma mark     设置默认的收藏
- (void)takeDefaultCollectCountry{
    
    NSArray  *defaultCurrecyArray = [NSArray  arrayWithObjects:@"CNY",@"USD",@"EUR",@"GBP",@"AUD",@"JPY",@"CAD",@"CHF", nil];
    NSMutableArray  *defaultCollectArray = [NSMutableArray array];
    for (NSDictionary   *dic  in [Util   readQuestionData]) {
        for (NSString  *currency in defaultCurrecyArray) {
            if ([[dic  allValues]  containsObject:currency]) {
                [defaultCollectArray  addObject:dic];
            }
        }
    }
    self.collectArray = defaultCollectArray;
    [Util  saveCollectCountry:defaultCollectArray];
}

#pragma mark     获取所有国家信息
- (NSMutableArray*)takeAllCountry{
    NSString  *pathString = [NSString  stringWithFormat:@"country"];
    NSURL  *url = [[NSBundle  mainBundle]  URLForResource:pathString withExtension:@"plist"];
    NSMutableArray  *array =  [NSMutableArray arrayWithContentsOfURL:url];
    return array;
}

#pragma mark  根据已选国家进行排序
- (void) makeOrderSelectedCountry{
    for (int i = 0; i< self.selestedCountry.count; i++) {
        NSString  *currency = [self.selestedCountry objectAtIndex:i];
        for (int j = 0;j< self.allCountry.count;j++) {
            NSDictionary *dic = [self.allCountry objectAtIndex:j];
            if ([[dic allValues]  containsObject:currency]) {
              [self.allCountry exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}

#pragma mark   从所有国家中剔除 已收藏
- (void)takeOutCollectCountryFromAll{
    
    NSMutableArray  *allCountry = [Util   readQuestionData];
    for (int i = 0; i< self.collectArray.count; i++) {
        NSDictionary  *countryDic = [self.collectArray  objectAtIndex:i];
        if ([allCountry  containsObject:countryDic]) {
            [allCountry  removeObject:countryDic];
        }
    }
    self.allCountry = allCountry;
}

#pragma mark  
#pragma mark          UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isSearch) {
        return 1;
    }else {
        if (self.collectArray.count == 0) {
            return 1;
        }else{
            return 2;
        }
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!self.isSearch  && self.collectArray.count!= 0) {
        UIView  *headerView = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, self.countryTable.frame.size.width, 31)];
        
        UIView  *contentView = [[UIView  alloc ] initWithFrame:CGRectMake(0, 1, self.countryTable.frame.size.width, 30)];
        contentView.backgroundColor = [UIColor  whiteColor];
        [headerView  addSubview:contentView];
        
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel  *titleLable = [[UILabel  alloc]  initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 30)];
        titleLable.backgroundColor = [UIColor  clearColor];
        titleLable.textColor = [UIColor  blackColor];
        titleLable.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:titleLable];
        if (section == 0) {
            titleLable.text = LOCALIZATION(@"Favorites");
        }else{
            titleLable.text = LOCALIZATION(@"ALL");
            UIView  *lineView = [[UIView  alloc ] initWithFrame:CGRectMake(15, 0, self.countryTable.frame.size.width, 1)];
            lineView.backgroundColor = [UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
            [headerView  addSubview:lineView];
        }
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.isSearch) {
        return 0;
    }else{
        if (self.collectArray.count == 0) {
            return 0;
        }
        return 31;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearch) {
        return self.resultArray.count;
    }else{
        if (self.collectArray.count == 0) {
            return self.allCountry.count;
        }else{
            if (section == 0) {
                return self.collectArray.count;
            }else{
                return self.allCountry.count;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 96;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static   NSString *idString = @"unitsCell";
    UnitsCell  *cell = [tableView  dequeueReusableHeaderFooterViewWithIdentifier:idString];
    if (cell == nil) {
        cell = [[[NSBundle  mainBundle]  loadNibNamed:@"UnitsCell" owner:self options:nil]  objectAtIndex:0];
        cell.selectionStyle = 0;
    }
    
    cell.delegate = self;
    NSDictionary *countryDic = nil;
    
    if (self.isSearch) {
        countryDic = [self.resultArray   objectAtIndex:indexPath.row];
    }else{
        if (self.collectArray.count == 0) {
            countryDic = [self.allCountry   objectAtIndex:indexPath.row];
        }else{
            if (indexPath.section == 0) {   //  已收藏
                countryDic = [self.collectArray   objectAtIndex:indexPath.row];
            }else{
                countryDic = [self.allCountry   objectAtIndex:indexPath.row];
            }
        }
    }
    
    NSString  *currentLanguage = nil;
    
    if ([[Localisator sharedInstance].currentLanguage  isEqualToString:@"zh-Hans"] || [[Localisator sharedInstance].currentLanguage  isEqualToString:@"zh-Hant"]) {
        currentLanguage = [[[Localisator sharedInstance].currentLanguage   componentsSeparatedByString:@"-"]  componentsJoinedByString:@""];
    }else{
        currentLanguage = [Localisator sharedInstance].currentLanguage;
    }
        cell.nameLable.text = [countryDic  objectForKey:currentLanguage];
        cell.nameAbb.text = [countryDic  objectForKey:@"currencyAbbreviated"];
        NSString  *country = [countryDic objectForKey:@"currencyAbbreviated"];
        cell.countryFlag.image = [UIImage  imageNamed:[NSString stringWithFormat:@"%@.png",country]];
    
    if ([cell.nameAbb.text  isEqualToString:[[NSLocale currentLocale]  objectForKey:NSLocaleCurrencyCode]]) {
        cell.dingWeiImage.image = [UIImage  imageNamed:@"定位.png"];
        cell.dingWeiImage.hidden = NO;
    }else{
        cell.dingWeiImage.hidden = YES;
    }
        return cell;
   }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPat
{
    NSDictionary  *selectDic = nil;
    if (self.isSearch) {
        selectDic = [self.resultArray   objectAtIndex:indexPat.row];
    }else{
        if (self.collectArray.count == 0) {
            selectDic = [self.allCountry   objectAtIndex:indexPat.row];
        }else{
            if (indexPat.section == 0) {
                selectDic = [self.collectArray   objectAtIndex:indexPat.row];
            }else{
                selectDic = [self.allCountry   objectAtIndex:indexPat.row];
            }
        }
    }
    if (self.delegate != nil && [self.delegate  respondsToSelector:@selector(selectedCountry:)]) {
        [self.delegate  selectedCountry:selectDic];
    }
    [self  backChangesViewController];
}

#pragma mark  Swipe Delegate
#pragma mark   MGSwipeTableCellDelegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
     return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    __weak CountryViewController * me = self;
    if (direction == MGSwipeDirectionLeftToRight) {   // 右滑
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.5;
        NSIndexPath  *index = [me.countryTable  indexPathForCell:cell];
        if ((index.section == 1 && self.collectArray.count != 0) ||(index.section == 0 && self.isSearch) || (index.section == 0 && self.collectArray.count == 0)) {
            return @[[MGSwipeButton buttonWithTitle:@""  icon:[UIImage  imageNamed:@"收藏@2x.png"]  backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:15 callback:^BOOL(MGSwipeTableCell *sender) {
                NSIndexPath * indexPath = [me.countryTable indexPathForCell:sender];
                [self  collectCountryAction:indexPath];  //   添加收藏
                return YES;
            }]];
        }
    }
    else {    //  左滑
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.5;
        CGFloat padding = 15;
        NSIndexPath  *index = [me.countryTable  indexPathForCell:cell];
        if (index.section == 0 &&  !self.isSearch && self.collectArray.count != 0){
            MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@""  icon:[UIImage  imageNamed:@"删除@2x.png"]  backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                NSIndexPath * indexPath = [me.countryTable indexPathForCell:sender];
                [self  cancleCollectCountryAction:indexPath];   //  取消收藏
                return YES;
            }];
            return @[trash];
        }
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
    NSLog(@"Swipe state: %@ ::: Gesture: %@", str, gestureIsActive ? @"Active" : @"Ended");
} 

#pragma mark   back
- (void)backChangesViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChangesViewController *changesVC = [storyboard instantiateViewControllerWithIdentifier:@"ChangesViewController"];
    [self  preformTransitionToViewController:changesVC direction:kCATransitionFromBottom];

}

#pragma mark    收藏国家
- (void)collectCountryAction:(NSIndexPath*)index{
    
    NSMutableDictionary  * dic = nil;
    if (self.isSearch) {
        dic = [self.resultArray  objectAtIndex:index.row];
    }else{
        dic = [self.allCountry  objectAtIndex:index.row];
    }
    
    if (![[Util  takeCollectCountry]  containsObject:dic]) {
        [self.collectArray addObject:dic];
        if (self.isSearch) {
            [self.resultArray  removeObject:dic];
        }else{
            [self.allCountry  removeObject:dic];
        }
        [Util saveCollectCountry:self.collectArray];
        [self  saveCollectCountryByNSUserDefaults:self.collectArray];
        [self.countryTable  reloadData];
    }

}

#pragma mark   取消收藏
- (void)cancleCollectCountryAction:(NSIndexPath*)index{
    
    NSMutableDictionary  *dic = [self.collectArray  objectAtIndex:index.row];
    [self.allCountry addObject:dic];
    [self.collectArray  removeObject:dic];
    [Util saveCollectCountry:self.collectArray];
    [self  saveCollectCountryByNSUserDefaults:self.collectArray];
    [self.countryTable  reloadData];

}

//  通过APP Group ID 建立共同的数据读写区，以供extension和containing app数据共享
- (void)saveCollectCountryByNSUserDefaults:(NSMutableArray*)collectCountry
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];       // APP Group ID
    [shared setObject:collectCountry forKey:@"collectCountry"];
    [shared synchronize];
}

- (void)takeOutAllCountryName{
    [self.filterArray  removeAllObjects];
    int  countArray = (int)self.allCountry.count;
    for (int i = 0; i< countArray; i++) {
        NSDictionary *dic = [self.allCountry objectAtIndex:i];
        NSString *country = [dic objectForKey:@"countryName"];
        [self.filterArray addObject:country];
    }
}

- (void)takeSearchResult:(NSArray*)result{
    int  count = (int)result.count;
     NSArray  *allValues = [NSMutableArray arrayWithArray:self.allCountry];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (int i = 0; i< allValues.count; i++) {
        NSDictionary *dic = [allValues  objectAtIndex:i];
        NSString  *countryName = [dic  objectForKey:@"countryName"];
        for (int j = 0; j< count; j++) {
            NSString *countryString = [result  objectAtIndex:j];
            if ([countryName isEqualToString:countryString]) {
                [resultArray addObject:dic];
            }
        }
    }
    self.resultArray = resultArray;
}

#pragma mark    UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.allCountry = [Util   readQuestionData];
    [self.countryTable reloadData];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length==0 || [searchText isEqualToString:@""]) {
        self.isSearch = NO;
        [self.countryTable  reloadData];
        return;
    }
    self.isSearch = YES;
    [self  predicateAllCountry:searchBar.text];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.isSearch = YES;
    [searchBar  resignFirstResponder];
    [self  predicateAllCountry:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar  resignFirstResponder];
    self.isSearch = NO;
    self.allCountry = [Util   readQuestionData];
    [self.countryTable reloadData];
}


#pragma mark    谓词过滤
- (void) predicateAllCountry:(NSString*)text{
    NSArray  *resultArray = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.currencyAbbreviated contains[cd] %@  or SELF.en contains[cd] %@ or SELF.de contains[cd] %@ or SELF.es contains[cd] %@ or SELF.pt contains[cd] %@ or SELF.ja contains[cd] %@ or SELF.zhHans contains[cd] %@ or SELF.zhHant contains[cd] %@ or SELF.fr contains[cd] %@", text,text,text,text,text,text,text,text,text]; // 过滤字典对象使用的谓词NSPredicate
    resultArray = [self.allCountry filteredArrayUsingPredicate:predicate];
    self.resultArray = [NSMutableArray  arrayWithArray:resultArray];
    [self.countryTable  reloadData];
}


- (void)reloadTableViewDataSource{
    self.isLoading = YES;
}

- (void)doneLoadingTableViewData{
    self.isLoading = NO;
    [_prevPullHeaderView pullHeaderScrollViewDataSourceDidFinishedLoading:self.countryTable];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)pullHeaderDidTrigger:(PullHeaderView*)view {
    if (view == _prevPullHeaderView) {
        [self backChangesViewController];
    }
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)pullHeaderSourceIsLoading:(PullHeaderView*)view {
    return self.isLoading;
}

- (NSString*)pullHeaderSubtext:(PullHeaderView*)view {
    NSString *subText;
    if (view == _prevPullHeaderView) {
        subText = @"[Previous article title]";
    } else {
        subText = @"[Next article title]";
    }
    return subText;
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_prevPullHeaderView pullHeaderScrollViewDidScroll:scrollView];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_prevPullHeaderView pullHeaderScrollViewDidEndDragging:scrollView];
}


- (void)preformTransitionToViewController:(UIViewController*)dest direction:(NSString*)direction {
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = direction; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop,kCATransitionFromBottom
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    NSMutableArray *stack = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stack removeLastObject];
    [stack addObject:dest];

    [self.navigationController setViewControllers:stack animated:NO];
}

#pragma mark 
#pragma  mark    UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
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
