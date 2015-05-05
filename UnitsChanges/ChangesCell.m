//
//  ChangesCell.m
//  UnitsChanges
//
//  Created by zhangmeng on 14/10/24.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import "ChangesCell.h"

@implementation ChangesCell

- (void)awakeFromNib {
    
    for (UIView *currentView in self.subviews){
        if ([NSStringFromClass([currentView class]) isEqualToString:@"UITableViewCellScrollView"])
        {
            UIScrollView *sv = (UIScrollView *) currentView;
            [sv setDelaysContentTouches:NO];
            break;
        }
    }

}


- (void)willTransitionToState:(UITableViewCellStateMask)state{
   
    [super willTransitionToState:state];
    
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                subview.hidden = YES;
                subview.alpha = 0.0;
            }
        }
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
