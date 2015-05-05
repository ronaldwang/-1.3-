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

@interface WatchSettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    UIToolbar *toolBar;
    UITextField   *activeField;
}

@property (weak, nonatomic) IBOutlet UITableView *valueTable;

@property (nonatomic,retain) NSMutableArray   *valueArray;

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
    [self  registerForKeyboardNotifications];
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
    return 70;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static   NSString  *identifier = @"WatchSettingCell";
    WatchSettingCell  *cell = [tableView  dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle  mainBundle ] loadNibNamed:@"WatchSettingCell" owner:self options:nil]  objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.inPutTextField  addTarget:self action:@selector(textInputAction:) forControlEvents:UIControlEventEditingDidEnd];
    
    [cell.inPutTextField  addTarget:self action:@selector(textFieldBegianAction:) forControlEvents:UIControlEventEditingDidBegin];
    
    cell.inPutTextField.tag = indexPath.row + 2015;
    cell.inPutTextField.text = [self.valueArray  objectAtIndex:indexPath.row];
    cell.inPutTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    cell.inPutTextField.inputAccessoryView = [self  createToolbar];
    
    cell.settingImage.image = [[UIImage imageNamed:[NSString stringWithFormat:@"%d-38.png",(int)indexPath.row+1]]  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.settingImage.tintColor = [Util  shareInstance].themeColor;
    
    cell.nameLable.text = [NSString stringWithFormat:@"QikNum %d",(int)indexPath.row + 1];

    return cell;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
       activeField = nil;
}

- (void)textFieldBegianAction:(UITextField*)sender{
    activeField = sender;
}

- (void)textInputAction:(UITextField*)sender{

    if (sender.text.length != 0) {
        if (![self.valueArray  containsObject:sender.text]) {
            [self.valueArray  replaceObjectAtIndex:sender.tag - 2015 withObject:sender.text];
            [Util  saveObligateValuesList:self.valueArray];
        }
    }else{
        sender.text = [self.valueArray  objectAtIndex:sender.tag - 2015];
    }

    [self.valueTable  reloadRowsAtIndexPaths:[NSArray  arrayWithObjects:[NSIndexPath  indexPathForRow:sender.tag-2015 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];

}


- (void)tapAction:(UITapGestureRecognizer*)sender{
    [self.view  endEditing:YES];
}


-(UIToolbar*) createToolbar {
    
    CGFloat   height = 34;
    if (iPhone6plus) {
        height = 42;
    }
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    toolBar.clipsToBounds = YES;
    
    toolBar.barTintColor = [Util   colorWithHexString:@"#d2d6db"];
    toolBar.tintColor = [Util  shareInstance].themeColor;
    toolBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldDone)];
    toolBar.items = @[space, done];
    return toolBar;
}


- (void)textFieldDone{
    
      [self.view  endEditing:YES];
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int   tag = (int)activeField.tag - 2015;
    
    if (tag > 3) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.valueTable.contentInset = contentInsets;
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
            [self.valueTable scrollRectToVisible:activeField.frame animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    self.valueTable.contentInset = contentInsets;
    [self.valueTable setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
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
