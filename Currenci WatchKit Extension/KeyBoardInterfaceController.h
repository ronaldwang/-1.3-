//
//  KeyBoardInterfaceController.h
//  Currenci
//
//  Created by Aries on 15/4/30.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@protocol KeyBoardInterfaceDelegate <NSObject>
- (void)keyBoardUserInput:(NSString*)input;
@end

@interface KeyBoardInterfaceControllerContext : NSObject    //  Context  通过Context传递数据
@property (weak, nonatomic) id <KeyBoardInterfaceDelegate> delegate;
@end


@interface KeyBoardInterfaceController : WKInterfaceController
@property (nonatomic,weak) id<KeyBoardInterfaceDelegate>delegate;
@end
