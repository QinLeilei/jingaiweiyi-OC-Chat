//
//  XMPPManager.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/12.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "TFXMPPManager.h"

NSString *const XMPPManagerHostName = @"52yifu.wang";
int const XMPPManagerHostPort = 5222;
NSString *const XMPPManagerUserName = @"XMPPManagerUserName";
NSString *const XMPPManagerPaseword = @"XMPPManagerPaseword";
NSString *const XMPPManagerLoginResultNotification = @"XMPPManagerLoginResultNotification";

@interface TFXMPPManager () <XMPPStreamDelegate,XMPPRosterDelegate>

// 重新连接模块
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
/** 存储失败的回掉 */
@property(nonatomic,strong) void (^failed) (NSString * errorMessage);

@end

@implementation TFXMPPManager
@synthesize xmppStream = _xmppStream;


+ (instancetype)shareInstace
{
    static TFXMPPManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;

}

#pragma mark - ******************** 懒加载
- (XMPPStream *)xmppStream
{
    if (_xmppStream == nil) {
        _xmppStream = [[XMPPStream alloc] init];
        
        // 实例化
        _xmppReconnect = [[XMPPReconnect alloc] init];
        _xmppRosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        _xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:_xmppRosterCoreDataStorage dispatchQueue:dispatch_get_global_queue(0, 0)];
        
        // 消息模块(如果支持多个用户，使用单例，所有的聊天记录会保存在一个数据库中)
        _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
        
        
        // 取消接收自动订阅功能，需要确认才能够添加好友！
        _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
        
        // 激活
        [_xmppReconnect activate:_xmppStream];
        [_xmppRoster activate:_xmppStream];
        [_xmppMessageArchiving activate:_xmppStream];
        
        // 添加代理
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

    }
    return _xmppStream;
}

#pragma mark - 连接方法
/** 断开连接 */
- (void)disconnect
{
    // 通知服务器，用户下线
    [self goOffline];
    
    [self.xmppStream disconnect];
}

/** 连接方法有失败block回调 */
- (BOOL)connectionWithName:(NSString *)name password:(NSString *)password failed:(void (^)(NSString *errorMessage))failed
{

    if (name.length == 0 || password.length == 0) {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:XMPPManagerUserName];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:XMPPManagerPaseword];
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.failed = [failed copy];
    
    // 需要指定myJID & hostName
    
    // 设置xmppStream的连接信息
    self.xmppStream.hostName = XMPPManagerHostName;
    self.xmppStream.hostPort = XMPPManagerHostPort;
    
    
    NSString *userName = [name stringByAppendingFormat:@"@%@", XMPPManagerHostName];
    
//    self.xmppStream.myJID = [XMPPJID jidWithString:userName resource:@"iPhone"];
    self.xmppStream.myJID = [XMPPJID jidWithString:userName];
    
    // 连接到服务器，如果连接已经存在，则不做任何事情
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:NULL];
    
    return YES;
}


#pragma mark - 用户的上线和下线
- (void)goOnline {
    XMPPPresence *p = [XMPPPresence presence];
    
    [self.xmppStream sendElement:p];
}


- (void)goOffline {
    XMPPPresence *p = [XMPPPresence presenceWithType:@"unavailable"];
    
    [self.xmppStream sendElement:p];
}


- (void)logout {
    // 所有用户信息是保存在用户偏好，注销应该删除用户偏好记录
    [self clearUserDefaults];
    // 下线，并且断开连接
    [self disconnect];
}

#pragma mark - 清除的方法

/** 清除用户的偏好 */
- (void)clearUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:XMPPManagerPaseword];
    [defaults removeObjectForKey:XMPPManagerUserName];
    
    [defaults synchronize];
}

/** 销毁调用 */
- (void)teardownXmppStream
{
    // 删除代理 禁用模块 清理缓存
    [self.xmppStream removeDelegate:self];
    [self.xmppRoster removeDelegate:self];
    
    // 取消激活
    [self.xmppReconnect deactivate];
    [self.xmppRoster deactivate];
    
    _xmppReconnect = nil;
    _xmppStream = nil;
    _xmppRosterCoreDataStorage = nil;
    _xmppRoster = nil;
    
}

#pragma mark - ******************** xmpp流代理方法
/** 连接成功时调用 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接成功");
    
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:XMPPManagerPaseword];
    
    if (self.isRegisterUser) {
        // 将用户密码发送给服务器，进行用户注册
        [self.xmppStream registerWithPassword:password error:NULL];
        
        self.isRegisterUser = NO;
    } else {
        // 将用户密码发送给服务器，进行用户登录
        [self.xmppStream authenticateWithPassword:password error:NULL];
    }
}

/** 断开连接时调用 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"断开连接");
    // 在主线程更新UI(用户自己断开的不算)
    if (self.failed && error) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"无法连接到服务器");});
    }
}

/** 授权成功时调用 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"授权成功");
    
    [self goOnline];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPManagerLoginResultNotification object:@(YES)];
    });
}

/** 授权失败时调用 */
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"授权失败error: %@", error);
    
    [self disconnect];

    [self clearUserDefaults];

    if (self.failed) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"用户名或者密码错误！");});
    }
    // 在主线程利用通知发送广播
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPManagerLoginResultNotification object:@(NO)];
    });
}

/** 注册成功时调用 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"注册成功");
    
    [self logout];
    [self clearUserDefaults];
    //    // 让用户上线
    //    [self goOnline];
    
    // 发送通知，切换控制器
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPManagerLoginResultNotification object:@(NO)];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"注册成功！～请登录");});
}

/** 注册失败时调用 */
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败: %@", error);
    
    if (self.failed) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"注册失败!");});
    }
}

#pragma mark - XMPP花名册代理
// 接收到订阅请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {

    NSString *msg = [NSString stringWithFormat:@"%@请求添加为好友，是否确认", presence.from];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
    }]];
    
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc
{
    [self teardownXmppStream];
}

@end
