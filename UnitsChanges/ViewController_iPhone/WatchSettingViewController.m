//
//  WatchSettingViewController.m
//  Currenci
//
//  Created by Aries on 15/3/26.
//  Copyright (c) 2015年 MR_ZhangM. All rights reserved.
//

#import "WatchSettingViewController.h"
#import "WatchSettingCell.h"
#import "Util.h"
#import <pop/POP.h>

@interface WatchSettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>
{
        NSInteger   currentIndex;
        BOOL  isEditting;
}

@property (weak, nonatomic) IBOutlet UITableView *valueTable;

@property (nonatomic,retain) NSMutableArray   *valueArray;

@property (nonatomic,retain) NSMutableString *textFieldText;


//  输入 键盘
@property (weak, nonatomic) IBOutlet UIView *keyBoardView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyBoardViewVerConstraint;


@end

@implementation WatchSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.valueArray = [NSMutableArray  arrayWithArray:[Util  takeObligateValuesList]];
    if (self.valueArray.count == 0) {
        self.valueArray = [NSMutableArray  arrayWithObjects:@"10",@"20",@"50",@"100",@"500",@"1000", nil];
        [Util  saveObligateValuesList:self.valueArray];
    }
    [self  drawNav];
    self.valueTable.contentSize = CGSizeMake(self.valueTable.frame.size.width,600);
    [self   addShadowForCalcuatorView];
}

- (void)addTapGesture{
  
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    [self.valueTable  addGestureRecognizer:tap];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)drawNav{
    
    UIButton  *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardButton.frame = CGRectMake(0, 0, 12, 20);
    [forwardButton  setBackgroundImage:[[UIImage imageNamed:@"forward.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //  UIImageRenderingMode   设置tintColor 时,图片的颜色可以根据此属性随设置的tintColor改变
    [forwardButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem   *leftItem = [[UIBarButtonItem  alloc ]  initWithCustomView:forwardButton];

    [self.navigationItem  setLeftBarButtonItem:leftItem animated:YES];
    
    self.navigationController.navigationBar.tintColor = [Util  shareInstance].themeColor;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:[Util  shareInstance].themeColor,NSForegroundColorAttributeName,[UIFont  fontWithName:@"HelveticaNeue-Light" size:20],NSFontAttributeName,nil]];

    self.title = LOCALIZATION(@"watchsetting");
    
    
}

- (void)backAction:(UIButton*)sender{
    [self.navigationController  popViewControllerAnimated:YES];
}

#pragma mark 
#pragma mark   ***UITableViewDataSource,UITableViewDelegate***
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static   NSString  *identifier = @"WatchSettingCell";
    WatchSettingCell  *cell = [tableView  dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle  mainBundle ] loadNibNamed:@"WatchSettingCell" owner:self options:nil]  objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.inPutTextField.delegate = self;
    
    cell.inPutTextField.tag = indexPath.row + 2015;
    cell.inPutTextField.text = [self.valueArray  objectAtIndex:indexPath.row];
    if (currentIndex == indexPath.row && isEditting) {
        cell.inPutTextField.textColor = [Util  shareInstance].themeColor;
    }else{
        cell.inPutTextField.textColor = [UIColor  darkGrayColor];
    }
    
    cell.settingImage.image = [[UIImage imageNamed:[NSString stringWithFormat:@"%d-38.png",(int)indexPath.row+1]]  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.settingImage.tintColor = [Util  shareInstance].themeColor;
    
    cell.nameLable.text = [NSString stringWithFormat:@"QikNum %d",(int)indexPath.row + 1];

    return cell;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    currentIndex = textField.tag - 2015;
    double   value = [Util  numberFormatterForFloat:textField.text];
    self.textFieldText =[NSMutableString  stringWithFormat:@"%d",(int)value];
    
    if (!isEditting) {
        [self   showOrHidenKeyBoard:YES];
    }
    [self changeCurrentTextFieldColor:textField];
    return NO;
}


- (void)changeCurrentTextFieldColor:(UITextField*)textField{
    
    [self.valueTable  reloadData];

}


- (void)tapAction:(UITapGestureRecognizer*)sender{
    if (isEditting) {
        [self  showOrHidenKeyBoard:NO];
    }
}


- (void)textFieldDone{
    
    UITextField   *textField = (UITextField*)[self.valueTable   viewWithTag:currentIndex + 2015];
    
    if (textField.text.length != 0) {
        if (![self.valueArray  containsObject:textField.text]) {
            [self.valueArray  replaceObjectAtIndex:currentIndex withObject:textField.text];
            [Util  saveObligateValuesList:self.valueArray];
        }
    }else{
        textField.text = [self.valueArray  objectAtIndex:currentIndex - 2015];
    }
    
    [self.valueTable  reloadRowsAtIndexPaths:[NSArray  arrayWithObjects:[NSIndexPath  indexPathForRow:currentIndex-2015 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
    
    [self  showOrHidenKeyBoard:NO];
    [self  changeCurrentTextFieldColor:nil];
}


#pragma mark
#pragma mark      输入键盘

- (IBAction)keyBoardClick:(UIButton *)sender {
    
    [self   addPopAnaitionClickButton:sender];
    
    if ([Util  isKeepingSound]) {
        AudioServicesPlaySystemSound(0x450);  //  系统自带按键声音
    }
    
    NSString  *inputString = sender.titleLabel.text;
    
    if (self.textFieldText.length <=9) {
        [self.textFieldText  appendString:inputString];
    }
    
    UITextField  *textField = (UITextField*)[self.valueTable  viewWithTag:currentIndex + 2015];
    textField.text = [Util  numberFormatterSetting:[NSString  stringWithFormat:@"%f",[Util numberFormatterForFloat:self.textFieldText]] withFractionDigits:2 withInput:YES];
    [self.valueArray  replaceObjectAtIndex:currentIndex withObject:textField.text];
    [Util  saveObligateValuesList:self.valueArray];
    [self.valueTable  reloadData];
    
}

- (IBAction)okButtonClick:(UIButton *)sender {
    [self   addPopAnaitionClickButton:sender];
    if ([Util  isKeepingSound]) {
        AudioServicesPlaySystemSound(0x450);  //  系统自带按键声音
    }
    [self  textFieldDone];
    
}

- (IBAction)clearClick:(UIButton *)sender {
    [self   addPopAnaitionClickButton:sender];
    if ([Util  isKeepingSound]) {
        AudioServicesPlaySystemSound(0x450);  //  系统自带按键声音
    }
    self.textFieldText = [NSMutableString string];
    UITextField  *textField = (UITextField*)[self.valueTable  viewWithTag:currentIndex + 2015];
    textField.text = @"0";
}

- (void)showOrHidenKeyBoard:(BOOL)show{
    
    isEditting = show;
    
    POPBasicAnimation   *basicAnimation = [POPBasicAnimation animation];
    basicAnimation.property = [POPMutableAnimatableProperty  propertyWithName:kPOPLayoutConstraintConstant];
    basicAnimation.duration = 0.5;
    
    if (show) {
        basicAnimation.fromValue = [NSNumber numberWithFloat:1000];
        basicAnimation.toValue = [NSNumber numberWithFloat:IPHONE_HEIGHT - self.keyBoardView.frame.size.height];
    }else{
        
        basicAnimation.fromValue = [NSNumber numberWithFloat:IPHONE_HEIGHT - self.keyBoardView.frame.size.height];
        basicAnimation.toValue = [NSNumber numberWithFloat:1000];
    }
    
    [self.keyBoardViewVerConstraint   pop_addAnimation:basicAnimation forKey:@"KeyBoardViewVerConstraint"];
    
}


- (void)addPopAnaitionClickButton:(UIButton*)button{
    
    POPBasicAnimation  *colcorAnimation = [POPBasicAnimation animation];
    colcorAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLabelTextColor];
    POPBasicAnimation  *scaleAnimation = [POPBasicAnimation animation];
    scaleAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayerScaleXY];
    POPBasicAnimation  *scaleEndAnimation = [POPBasicAnimation animation];
    scaleEndAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLayerScaleXY];
    POPBasicAnimation  *colcorEndAnimation = [POPBasicAnimation animation];
    colcorEndAnimation.property = [POPAnimatableProperty  propertyWithName:kPOPLabelTextColor];
    colcorAnimation.toValue = [Util shareInstance].themeColor;
    colcorEndAnimation.toValue = [UIColor  colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:1.0];
    scaleAnimation.toValue = [NSValue  valueWithCGPoint:CGPointMake(1.5, 1.5)];
    scaleEndAnimation.toValue = [NSValue  valueWithCGPoint:CGPointMake(1.0, 1.0)];
    colcorAnimation.duration = 0.15f;
    scaleEndAnimation.duration = 0.15;
    scaleAnimation.duration = 0.15;
    colcorEndAnimation.duration = 0.15;
    colcorEndAnimation.fromValue = [Util shareInstance].themeColor;
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [button.layer  pop_addAnimation:scaleEndAnimation forKey:@"scaleEnd"];
        }
    };
    colcorAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [button.titleLabel  pop_addAnimation:colcorEndAnimation forKey:@"colorEnd"];
        }
    };
    [button.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
    [button.titleLabel  pop_addAnimation:colcorAnimation forKey:@"pop"];
    
}


- (void)addShadowForCalcuatorView{
    [self.keyBoardView.layer  setShadowOffset:CGSizeMake(0,-0.5)];
    [self.keyBoardView.layer setShadowRadius:0.25];
    [self.keyBoardView.layer  setShadowOpacity:0.08];
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
