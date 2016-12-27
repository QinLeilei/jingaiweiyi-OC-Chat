//
//  TestVC.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/21.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "TestVC.h"

@interface TestVC ()
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation TestVC

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center = _recordButton.center;
        [self.view addSubview:_indicator];
    }
    return _indicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
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
