//
//  LoginVC.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/9.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "LoginVC.h"
#import "RegisterVC.h"
@interface LoginVC () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *headerImageV;
@property (nonatomic, strong) UITextField *nameTextF;
@property (nonatomic, strong) UITextField *passwordTextF;
@property (strong, nonatomic) UIButton *loginButton;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"登录";
    [self setupNavigationBarItem:@""];
    [self setupUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupUI
{
    [self.view addSubview:self.headerImageV];
    [self.headerImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(100);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    [self.view addSubview:self.nameTextF];
    [self.nameTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImageV.mas_bottom).offset(8);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.mas_offset(30);
    }];
    
    [self.view addSubview:self.passwordTextF];
    [self.passwordTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameTextF.mas_bottom).offset(8);
        make.left.equalTo(self.nameTextF.mas_left);
        make.right.equalTo(self.nameTextF.mas_right);
        make.height.mas_offset(30);
    }];
    
    [self.view addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextF.mas_bottom).offset(8);
        make.left.equalTo(self.passwordTextF.mas_left);
        make.right.equalTo(self.passwordTextF.mas_right);
        make.height.mas_offset(30);
    }];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [findButton setTitle:@"无法登陆?" forState:UIControlStateNormal];
    [self.view addSubview:findButton];
    [findButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loginButton.mas_left)
        ;
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [registerButton setTitle:@"新账号" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.loginButton.mas_right)
        ;
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
    
    [findButton handleClickEvent:UIControlEventTouchUpInside withClickBlock:^(UIButton *sender) {
        
    }];
    
    [registerButton handleClickEvent:UIControlEventTouchUpInside withClickBlock:^(UIButton *sender) {
        RegisterVC *VC = [[RegisterVC alloc] init];
        VC.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:VC animated:YES];
    }];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *oldText = textField.text;
    NSString *currInputText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if (textField == self.nameTextF) {
        if (currInputText.length>0 && self.passwordTextF.text.length) {
            self.loginButton.enabled = YES;
        }
    }
    
    if (textField == self.passwordTextF) {
        if (currInputText.length>0 && self.nameTextF.text.length) {
            self.loginButton.enabled = YES;

        }
    }
    if ((currInputText.length == oldText.length && range.location == 0)) {
        self.loginButton.enabled = NO;
    }
    
    return YES;
}

- (UIButton *)loginButton
{
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"登陆" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"login_btn_blue_nor"] forState:UIControlStateNormal];
        _loginButton.titleLabel.font = kSysFont(14);
        _loginButton.enabled = NO;
        [_loginButton handleClickEvent:UIControlEventTouchUpInside withClickBlock:^(UIButton *sender) {
            [[TFXMPPManager shareInstace] connectionWithName:self.nameTextF.text password:self.passwordTextF.text failed:^(NSString *errorMessage) {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }];
        }];
        
        _loginButton.enabled = YES;
    }
    return _loginButton;
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
        
        _nameTextF.text = @"test002";
    }
    return _nameTextF;
}

- (UITextField *)passwordTextF
{
    if (!_passwordTextF) {
        _passwordTextF = [UITextField new];
        _passwordTextF.font = kSysFont(14);
        _passwordTextF.delegate = self;
        _passwordTextF.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextF.placeholder = @"密码";
        _passwordTextF.textAlignment = NSTextAlignmentCenter;
        
        _passwordTextF.text = @"123456";
    }
    return _passwordTextF;
}

- (UIImageView *)headerImageV
{
    if (!_headerImageV) {
        _headerImageV = [UIImageView new];
        _headerImageV.layer.cornerRadius = 80 * 0.5;
        _headerImageV.layer.masksToBounds = YES;
        _headerImageV.image = [UIImage imageNamed:@"login_avatar_default.jpg"];
        _headerImageV.backgroundColor = TF_RANDOM_COLOR;
    }
    return _headerImageV;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
