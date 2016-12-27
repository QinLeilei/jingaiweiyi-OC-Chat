//
//  AppDelegate.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/9.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginVC.h"
#import "MyTabBar.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusWithNotification:) name:XMPPManagerLoginResultNotification object:nil];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPManagerUserName];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPManagerPaseword];
    if (![[TFXMPPManager shareInstace] connectionWithName:userName password:password failed:nil]) {
        [self setupWindowViewControllerWithName:@"LoginVC"];
    }
    
    [self.window makeKeyAndVisible];

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {

    [[TFXMPPManager shareInstace] disconnect];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPManagerUserName];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPManagerPaseword];
    [[TFXMPPManager shareInstace] connectionWithName:userName password:password failed:^(NSString *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的密码可能在其他的计算机上被修改，请重新登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}


- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)loginStatusWithNotification:(NSNotification *)notification {
    NSLog(@"notification.object: %@", notification.object);
    
    if ([notification.object intValue]) {
        [self setupWindowViewControllerWithName:@"MyTabBar"];
    } else{
        [self setupWindowViewControllerWithName:@"LoginVC"];
    }
}
- (void)setupWindowViewControllerWithName:(NSString *)name {

    UIViewController *VC = nil;
    if ([name isEqualToString:@"MyTabBar"]) {
        MyTabBar *tabBarVC = [[MyTabBar alloc] init];
        VC = tabBarVC;
        
    } else {
        LoginVC *loginVC = [[LoginVC alloc] init];
        UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
        VC = navigationVC;
    }
    
    self.window.rootViewController = VC;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
