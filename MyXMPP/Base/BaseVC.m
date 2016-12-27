//
//  BaseVC.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/9.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC
- (void)dealloc
{
    NSLog(@"%@释放了", self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)setupNavigationBarItemBackText:(NSString *)text
{
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] init];
    backBarButtonItem.title = text;
    self.navigationItem.backBarButtonItem.title = text;
}

- (void)setupNavigationBarItem:(NSString *)text
{
//    self.title = [NSString stringWithFormat:@"%@", self.class];

    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStylePlain target:self action:@selector(nextBarbarBtnClick:)];
    self.navigationItem.rightBarButtonItem = barBtn;
}

- (void)nextBarbarBtnClick:(UIBarButtonItem *)sender
{
    
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
