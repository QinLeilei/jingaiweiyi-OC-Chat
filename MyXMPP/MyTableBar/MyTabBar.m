//
//  MyTabBar.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/12.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "MyTabBar.h"
#import "MessageVC.h"
#import "FriendsVC.h"
#import "DynamicVC.h"
@interface MyTabBar ()

@end

@implementation MyTabBar

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}
- (void)setupUI {
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"login_btn_blue_nor"] forBarMetrics:UIBarMetricsDefault];
    
    //导航字体属性
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0],
                                                           NSForegroundColorAttributeName:
                                                               [UIColor blackColor]
                                                           }];
    MessageVC *messageVC = [[MessageVC alloc] init];
    FriendsVC *friendsVC = [[FriendsVC alloc] init];
    DynamicVC *dynamicVC = [[DynamicVC alloc] init];
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:messageVC, friendsVC, dynamicVC, nil];
    NSArray *titleArr = [NSArray arrayWithObjects:
                         @"消息",
                         @"联系人",
                         @"动态", nil];
    NSArray *selImageArr = [NSArray arrayWithObjects:
                            @"tab_recent_press",
                            @"tab_buddy_press",
                            @"tab_qworld_press", nil];
    NSArray *norImageArr = [NSArray arrayWithObjects:
                            @"tab_recent_nor",
                            @"tab_buddy_nor",
                            @"tab_qworld_nor", nil];
    
    for (int i = 0; i<titleArr.count; i++) {
        
        UIViewController *vc = array[i];
        vc.title = titleArr[i];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        [array replaceObjectAtIndex:i withObject:nc];
        
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
        tabBarItem.title = titleArr[i];
        tabBarItem.selectedImage = [UIImage imageNamed:selImageArr[i]];
        tabBarItem.image = [UIImage imageNamed:norImageArr[i]];
        vc.tabBarItem = tabBarItem;
    }
    self.viewControllers = array;
    self.selectedIndex = 0;
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
