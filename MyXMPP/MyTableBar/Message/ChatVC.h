//
//  ChatVC.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/13.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "BaseVC.h"

@interface ChatVC : BaseVC
/** 聊天对象的JID */
@property (nonatomic, strong) XMPPJID *chatJID;
@end
