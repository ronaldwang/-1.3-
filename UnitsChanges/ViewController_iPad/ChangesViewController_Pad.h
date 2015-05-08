//
//  ChangesViewController.h
//  Currency_PAD
//
//  Created by Aries on 15/4/21.
//  Copyright (c) 2015年 Xi'an DevaTech. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SplitDetailViweController;

@interface ChangesViewController_Pad: UIViewController
@property (weak, nonatomic) IBOutlet UITableView *changeTable;

@property  (nonatomic,retain) NSMutableDictionary  *rateDic;
@property (strong, nonatomic)  SplitDetailViweController *detailViewController;
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)resetNumberUnderMove:(id)sender;

@end
