//
//  BaseVC.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/9.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseVC : UIViewController

- (void)setupNavigationBarItemBackText:(NSString *)text;
- (void)setupNavigationBarItem:(NSString *)text;
- (void)nextBarbarBtnClick:(UIBarButtonItem *)sender;

@end
