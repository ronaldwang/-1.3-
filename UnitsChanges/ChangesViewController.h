//
//  ChangesViewController.h
//  UnitsChanges
//
//  Created by zhangmeng on 14/10/24.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangesViewController :UIViewController
@property (weak, nonatomic) IBOutlet UITableView *changesTableView;
@property  (nonatomic,retain) NSMutableDictionary  *rateDic;
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)resetNumberUnderMove:(id)sender;
@end
