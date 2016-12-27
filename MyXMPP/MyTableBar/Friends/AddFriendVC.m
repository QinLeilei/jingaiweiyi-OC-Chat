//
//  AddFriendVC.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/12.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "AddFriendVC.h"

@interface AddFriendVC () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *nameTextF;
@property (strong, nonatomic) UIButton *addButton;

@end

@implementation AddFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"添加朋友";
    
    [self setupUI];
}

- (void)setupUI
{
    [self.view addSubview:self.nameTextF];
    [self.nameTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20 + kStatusBar_And_NavigationBar_Height);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.mas_offset(30);
    }];

    [self.view addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameTextF.mas_bottom).offset(8);
        make.left.equalTo(self.nameTextF.mas_left);
        make.right.equalTo(self.nameTextF.mas_right);
        make.height.mas_offset(30);
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *oldText = textField.text;
    NSString *currInputText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if (textField == self.nameTextF) {
        if (currInputText.length>0) {
            self.addButton.enabled = YES;
        }
    }
    
    if ((currInputText.length == oldText.length && range.location == 0)) {
        self.addButton.enabled = NO;
    }
    
    return YES;
}



- (UITextField *)nameTextF
{
    if (!_nameTextF) {
        _nameTextF = [[UITextField alloc] init];
        _nameTextF.font = kSysFont(14);
        _nameTextF.borderStyle = UITextBorderStyleRoundedRect;
        _nameTextF.placeholder = @"账号";
        _nameTextF.delegate = self;
        _nameTextF.textAlignment = NSTextAlignmentCenter;
    }
    return _nameTextF;
}

- (UIButton *)addButton
{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setTitle:@"查找" forState:UIControlStateNormal];
        [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addButton setBackgroundImage:[UIImage imageNamed:@"login_btn_blue_nor"] forState:UIControlStateNormal];
        _addButton.titleLabel.font = kSysFont(14);
        _addButton.enabled = NO;
        [_addButton handleClickEvent:UIControlEventTouchUpInside withClickBlock:^(UIButton *sender) {
            
            NSString *name = self.nameTextF.text;
            
            NSRange range = [name rangeOfString:@"@"];
            if (range.location == NSNotFound) {
                name = [name stringByAppendingFormat:@"@%@", [TFXMPPManager shareInstace].xmppStream.myJID.domain];
            }
            
            // 如果已经是好友就不需要再次添加
            XMPPJID *jid = [XMPPJID jidWithString:name];
            
            BOOL contains = [[TFXMPPManager shareInstace].xmppRosterCoreDataStorage userExistsWithJID:jid xmppStream:[TFXMPPManager shareInstace].xmppStream];
            
            if (contains) {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"已经是好友，无需添加" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
            
            [[TFXMPPManager shareInstace].xmppRoster subscribePresenceToUser:jid];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _addButton;
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
