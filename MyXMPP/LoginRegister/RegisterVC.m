//
//  RegisterVC.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/12.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "RegisterVC.h"

@interface RegisterVC () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *nameTextF;
@property (nonatomic, strong) UITextField *passwordTextF;
@property (strong, nonatomic) UIButton *registerButton;
@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"注册";
    [self setupNavigationBarItemBackText:@"登录"];
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
    
    [self.view addSubview:self.passwordTextF];
    [self.passwordTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameTextF.mas_bottom).offset(8);
        make.left.equalTo(self.nameTextF.mas_left);
        make.right.equalTo(self.nameTextF.mas_right);
        make.height.mas_offset(30);
    }];
    
    [self.view addSubview:self.registerButton];
    [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextF.mas_bottom).offset(8);
        make.left.equalTo(self.passwordTextF.mas_left);
        make.right.equalTo(self.passwordTextF.mas_right);
        make.height.mas_offset(30);
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *oldText = textField.text;
    NSString *currInputText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if (textField == self.nameTextF) {
        if (currInputText.length>0 && self.passwordTextF.text.length) {
            self.registerButton.enabled = YES;
        }
    }
    
    if (textField == self.passwordTextF) {
        if (currInputText.length>0 && self.nameTextF.text.length) {
            self.registerButton.enabled = YES;
            
        }
    }
    if ((currInputText.length == oldText.length && range.location == 0)) {
        self.registerButton.enabled = NO;
    }
    
    return YES;
}

- (UIButton *)registerButton
{
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton setBackgroundImage:[UIImage imageNamed:@"login_btn_blue_nor"] forState:UIControlStateNormal];
        _registerButton.enabled = NO;
        _registerButton.titleLabel.font = kSysFont(14);
        
        [_registerButton handleClickEvent:UIControlEventTouchUpInside withClickBlock:^(UIButton *sender) {
            [TFXMPPManager shareInstace].isRegisterUser = YES;
            [[TFXMPPManager shareInstace] connectionWithName:self.nameTextF.text password:self.passwordTextF.text failed:^(NSString *errorMessage) {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }];
        }];
    }
    return _registerButton;
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

- (UITextField *)passwordTextF
{
    if (!_passwordTextF) {
        _passwordTextF = [UITextField new];
        _passwordTextF.font = kSysFont(14);
        _passwordTextF.delegate = self;
        _passwordTextF.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextF.placeholder = @"密码";
        _passwordTextF.textAlignment = NSTextAlignmentCenter;
    }
    return _passwordTextF;
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
