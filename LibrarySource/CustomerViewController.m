//
//  CustomerViewController.m
//  Currenci
//
//  Created by Aries on 15/5/11.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "CustomerViewController.h"

@interface CustomerViewController ()

@end

@implementation CustomerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
    const CGFloat kMasterViewWidth = 240.0;
    
    UIViewController *masterViewController = [self.viewControllers objectAtIndex:0];
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    
    if (detailViewController.view.frame.origin.x > 0.0) {
        // Adjust the width of the master view
//        CGRect masterViewFrame = masterViewController.view.frame;
//        CGFloat deltaX = masterViewFrame.size.width - kMasterViewWidth;
//        masterViewFrame.size.width -= deltaX;
//        masterViewController.view.frame = masterViewFrame;
//        
//        // Adjust the width of the detail view
//        CGRect detailViewFrame = detailViewController.view.frame;
//        detailViewFrame.origin.x -= deltaX;
//        detailViewFrame.size.width += deltaX;
//        detailViewController.view.frame = detailViewFrame;
//        
//        [masterViewController.view setNeedsLayout];
//        [detailViewController.view setNeedsLayout];
    
    }
}



-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation   duration:duration];
    
    NSMutableArray *controllers=[NSMutableArray    arrayWithArray:self.viewControllers];
    UIViewController * first=[controllers objectAtIndex:0];
    UIViewController * second=[controllers objectAtIndex:1];
    
    [self setViewControllers:[NSArray arrayWithObjects:second,first,nil]];
    
    NSLog(@"%@\n%@",first,second);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
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
