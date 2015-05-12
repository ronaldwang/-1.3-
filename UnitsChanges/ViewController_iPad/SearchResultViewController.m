//
//  SearchResultViewController.m
//  Currency_PAD
//
//  Created by Aries on 15/4/23.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import "SearchResultViewController.h"
#import "UnitsCell.h"
#import "Util.h"

@interface SearchResultViewController ()<MGSwipeTableCellDelegate>

@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 96;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     static   NSString *Identifier =  @"UnitsCurrencyCell";
    
     UnitsCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
     
    cell.delegate = self;
    NSDictionary *countryDic = [self.searchResults  objectAtIndex:indexPath.row];

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
      NSDictionary  *selectDic = [self.searchResults  objectAtIndex:indexPath.row];

     [[NSNotificationCenter  defaultCenter] postNotificationName:@"SelectedCurrecyChanged" object:nil userInfo:selectDic];
    
     [self.presentingViewController.navigationController  popViewControllerAnimated:YES];
    
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
