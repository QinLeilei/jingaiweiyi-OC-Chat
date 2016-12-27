//
//  XMPPManager.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/12.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

extern NSString *const XMPPManagerHostName;
extern int const XMPPManagerHostPort;

extern NSString *const XMPPManagerUserName;
extern NSString *const XMPPManagerPaseword;

// 登录结果通知(成功／失败)
extern NSString *const XMPPManagerLoginResultNotification;
@interface TFXMPPManager : NSObject

// 是否是注册用户的标记
@property (nonatomic, assign) BOOL isRegisterUser;

/** xmpp流 */
@property(nonatomic, strong, readonly) XMPPStream *xmppStream;
@property(nonatomic,strong) XMPPRoster *xmppRoster;
@property(nonatomic,strong) XMPPRosterCoreDataStorage * xmppRosterCoreDataStorage;

/** 消息归档 */
@property (nonatomic, strong, readonly) XMPPMessageArchiving *xmppMessageArchiving;
/** 消息归档存储 */
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;


+ (instancetype)shareInstace;
- (BOOL)connectionWithName:(NSString *)name password:(NSString *)password failed:(void (^)(NSString *errorMessage))failed;
- (void)disconnect;

- (void)logout;
@end
