//
//  CurrencyController.m
//  Currency_PAD
//
//  Created by Aries on 15/4/23.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import "CurrencyController.h"

#import "UnitsCell.h"
#import "Util.h"

#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

#import "SearchResultViewController.h"

@interface CurrencyController ()<UISearchResultsUpdating, UISearchBarDelegate,MGSwipeTableCellDelegate>

@property (nonatomic,strong) NSMutableArray  *allCurrency;
@property (nonatomic,strong) NSMutableArray *collectArray;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results

@end

@implementation CurrencyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self  drawNavigationBarv];
    
    if ([Util  takeCollectCountry].count != 0) {
        self.collectArray = [NSMutableArray  arrayWithArray:[Util takeCollectCountry]];
    }else{
        self.allCurrency = [NSMutableArray  arrayWithArray:[Util   readQuestionData]];
        [self  takeDefaultCollectCountry];
    }
    
    [self  takeOutCollectCountryFromAll];
    
    // Create a mutable array to contain products for the search results table.
    self.searchResults = [NSMutableArray  array];
    
    // The table view controller is in a nav controller, and so the containing nav controller is the 'search results controller'
    UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TableSearchResultsNavController"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.placeholder = LOCALIZATION(@"search");
    self.searchController.searchBar.tintColor = [Util shareInstance].themeColor;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    
    self.navigationController.navigationBar.tintColor = [Util shareInstance].themeColor;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [[NSNotificationCenter  defaultCenter]  removeObserver:self name:@"LanguageChanged" object:nil];
    [[NSNotificationCenter  defaultCenter]  removeObserver:self name:@"SelectedColorChanged" object:nil];

    
    [[NSNotificationCenter  defaultCenter]  addObserver:self selector:@selector(selectedLanguageChanged:) name:@"LanguageChanged" object:nil];
    
    [[NSNotificationCenter  defaultCenter]  addObserver:self selector:@selector(selectedColorChanged:) name:@"SelectedColorChanged" object:nil];

}


- (void)selectedLanguageChanged:(NSNotification*)sender{
    self.searchController.searchBar.placeholder = LOCALIZATION(@"search");
    [self.tableView   reloadData];
}

- (void)selectedColorChanged:(NSNotification*)sender{
    self.navigationController.navigationBar.tintColor = [Util  shareInstance].themeColor;
     self.searchController.searchBar.tintColor = [Util shareInstance].themeColor;
}

#pragma  amrk   设置 导航 栏
//  设置 导航 栏
- (void)drawNavigationBarv{
    
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 12, 20);
    [button  setBackgroundImage:[[UIImage imageNamed:@"forward.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //  UIImageRenderingMode   设置tintColor 时,图片的颜色可以根据此属性随设置的tintColor改变
    
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem   *leftItem = [[UIBarButtonItem  alloc ]  initWithCustomView:button];
    [self.navigationItem  setLeftBarButtonItem:leftItem animated:YES];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

//   返回
- (void)backAction:(UIButton*)sender{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark   从所有国家中剔除 已收藏
- (void)takeOutCollectCountryFromAll{
    
    NSMutableArray  *allCountry = [Util   readQuestionData];
    for (int i = 0; i< self.collectArray.count; i++) {
        NSDictionary  *countryDic = [self.collectArray  objectAtIndex:i];
        if ([allCountry  containsObject:countryDic]) {
            [allCountry  removeObject:countryDic];
        }
    }
    self.allCurrency = allCountry;
}


#pragma mark
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.collectArray.count == 0) {
        return 1;
    }else{
        return 2;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.collectArray.count == 0) {
        return self.allCurrency.count;
    }else{
        if (section == 0) {
            return self.collectArray.count;
        }else{
            return self.allCurrency.count;
        }
    }
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if ( self.collectArray.count!= 0) {
        UIView  *headerView = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 31)];
        
        UIView  *contentView = [[UIView  alloc ] initWithFrame:CGRectMake(0, 1, self.tableView.frame.size.width, 30)];
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
            UIView  *lineView = [[UIView  alloc ] initWithFrame:CGRectMake(15, 0, self.tableView.frame.size.width, 1)];
            lineView.backgroundColor = [UIColor  colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
            [headerView  addSubview:lineView];
        }
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
        if (self.collectArray.count == 0) {
            return 0;
        }
        return 31;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 96;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static   NSString *identifier = @"UnitsCurrencyCell";
    
    UnitsCell  *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    NSDictionary *countryDic = nil;
    
        if (self.collectArray.count == 0) {
            countryDic = [self.allCurrency   objectAtIndex:indexPath.row];
        }else{
            if (indexPath.section == 0) {   //  已收藏
                countryDic = [self.collectArray   objectAtIndex:indexPath.row];
            }else{
                countryDic = [self.allCurrency   objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        NSDictionary  *selectDic = nil;
   
        if (self.collectArray.count == 0) {
            selectDic = [self.allCurrency   objectAtIndex:indexPath.row];
        }else{
            if (indexPath.section == 0) {
                selectDic = [self.collectArray   objectAtIndex:indexPath.row];
            }else{
                selectDic = [self.allCurrency   objectAtIndex:indexPath.row];
            }
        }
    
    if (self.delegate != nil && [self.delegate  respondsToSelector:@selector(selectedCountry:)]) {
        [self.delegate  selectedCountry:selectDic];
    }
    
    [self.navigationController  popViewControllerAnimated:YES];


}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    __weak CurrencyController * me = self;
    if (direction == MGSwipeDirectionLeftToRight) {   // 右滑
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.5;
        NSIndexPath  *index = [me.tableView  indexPathForCell:cell];
        if ((index.section == 1 && self.collectArray.count != 0) || (index.section == 0 && self.collectArray.count == 0)) {
            return @[[MGSwipeButton buttonWithTitle:@""  icon:[UIImage  imageNamed:@"收藏@2x.png"]  backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:15 callback:^BOOL(MGSwipeTableCell *sender) {
                NSIndexPath * indexPath = [me.tableView indexPathForCell:sender];
                [self  collectCountryAction:indexPath];  //   添加收藏
                return YES;
            }]];
        }
    }
    else {    //  左滑
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.5;
        CGFloat padding = 15;
        NSIndexPath  *index = [me.tableView  indexPathForCell:cell];
        if (index.section == 0  && self.collectArray.count != 0){
            MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@""  icon:[UIImage  imageNamed:@"删除@2x.png"]  backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                NSIndexPath * indexPath = [me.tableView indexPathForCell:sender];
                [self  cancleCollectCountryAction:indexPath];   //  取消收藏
                return YES;
            }];
            return @[trash];
        }
    }
    return nil;
}


#pragma mark    收藏国家
- (void)collectCountryAction:(NSIndexPath*)index{
    
    NSMutableDictionary  * dic = [self.allCurrency  objectAtIndex:index.row];

    
    if (![[Util  takeCollectCountry]  containsObject:dic]) {
        [self.collectArray addObject:dic];
        
        [self.allCurrency  removeObject:dic];
        
        [Util saveCollectCountry:self.collectArray];
        [self  saveCollectCountryByNSUserDefaults:self.collectArray];
        [self.tableView  reloadData];
    }
    
}

#pragma mark   取消收藏
- (void)cancleCollectCountryAction:(NSIndexPath*)index{
    
    NSMutableDictionary  *dic = [self.collectArray  objectAtIndex:index.row];
    [self.allCurrency addObject:dic];
    [self.collectArray  removeObject:dic];
    [Util saveCollectCountry:self.collectArray];
    [self  saveCollectCountryByNSUserDefaults:self.collectArray];
    [self.tableView  reloadData];
    
}

//  通过APP Group ID 建立共同的数据读写区，以供extension和containing app数据共享
- (void)saveCollectCountryByNSUserDefaults:(NSMutableArray*)collectCountry
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];       // APP Group ID
    [shared setObject:collectCountry forKey:@"collectCountry"];
    [shared synchronize];
}



#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.searchController.searchBar text];
    
    [self updateFilteredContentForProductName:searchString];
    
    if (self.searchController.searchResultsController) {
        UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
        
        SearchResultViewController *vc = (SearchResultViewController *)navController.topViewController;
        vc.searchResults = self.searchResults;
        [vc.tableView reloadData];
    }
    
}

#pragma mark - UISearchBarDelegate

// Workaround for bug: -updateSearchResultsForSearchController: is not called when scope buttons change
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.searchController.searchBar.placeholder = LOCALIZATION(@"search");
    self.searchController.searchBar.tintColor = [Util shareInstance].themeColor;
}



#pragma mark - Content Filtering

- (void)updateFilteredContentForProductName:(NSString *)productName{
    
    [self.searchResults removeAllObjects]; // First clear the filtered array.
    
    /*  Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
     */
    for (NSDictionary *product in [Util  readQuestionData]) {
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            
            NSRange  currencyAbbreviatedRange = NSMakeRange(0, [[product objectForKey:@"currencyAbbreviated"]  length]);
            NSRange deRange = NSMakeRange(0, [[product objectForKey:@"de"]  length]);
            NSRange enRange = NSMakeRange(0, [[product objectForKey:@"en"]  length]);
            NSRange esRange = NSMakeRange(0, [[product objectForKey:@"es"]  length]);
            NSRange frRange = NSMakeRange(0, [[product objectForKey:@"fr"]  length]);
            NSRange jaRange = NSMakeRange(0, [[product objectForKey:@"ja"]  length]);
            NSRange ptRange = NSMakeRange(0, [[product objectForKey:@"pt"]  length]);
            NSRange zhHansRange = NSMakeRange(0, [[product objectForKey:@"zhHans"]  length]);
            NSRange zhHantRange = NSMakeRange(0, [[product objectForKey:@"zhHant"]  length]);
            
             NSRange foundRangeCurAbb = [[product objectForKey:@"currencyAbbreviated"] rangeOfString:productName options:searchOptions range:currencyAbbreviatedRange];
            
            NSRange foundRangeDe = [[product objectForKey:@"de"] rangeOfString:productName options:searchOptions range:deRange];
            NSRange foundRangeEn = [[product objectForKey:@"en"] rangeOfString:productName options:searchOptions range:enRange];
             NSRange foundRangeEs = [[product objectForKey:@"es"] rangeOfString:productName options:searchOptions range:esRange];
             NSRange foundRangeFr = [[product objectForKey:@"fr"] rangeOfString:productName options:searchOptions range:frRange];
             NSRange foundRangeJa = [[product objectForKey:@"ja"] rangeOfString:productName options:searchOptions range:jaRange];
             NSRange foundRangePt = [[product objectForKey:@"pt"] rangeOfString:productName options:searchOptions range:ptRange];
             NSRange foundRangeZhHans = [[product objectForKey:@"zhHans"] rangeOfString:productName options:searchOptions range:zhHansRange];
            NSRange foundRangeZhHant = [[product objectForKey:@"zhHant"] rangeOfString:productName options:searchOptions range:zhHantRange];
            
            if (foundRangeCurAbb.length > 0 || foundRangeDe.length > 0 ||  foundRangeEn.length > 0 || foundRangeEs.length > 0 || foundRangeFr.length > 0 || foundRangeJa.length > 0 ||  foundRangePt.length > 0 || foundRangeZhHans.length > 0 || foundRangeZhHant.length > 0) {
                [self.searchResults addObject:product];

        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
