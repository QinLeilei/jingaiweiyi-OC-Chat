//
//  ICMessage.m
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/3/10.
//  Copyright © 2016年 gxz All rights reserved.
//

#import "ICMessage.h"
#import "TFXMPPManager.h"
#import "ICMessageConst.h"
@implementation ICMessage

+ (ICMessage *)resolveWithXMPPMessageArchiving_Message_CoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)xmppMessage {
    
    NSLog(@"xmppMessage: %@", [xmppMessage printObjectAllProperty]);
    NSLog(@"bareJid: %@", [xmppMessage.bareJid printObjectAllProperty]);
    NSLog(@"message: %@", [xmppMessage.message printObjectAllProperty]);
    
    
    ICMessage *message    = [[ICMessage alloc] init];
    
    message.to = xmppMessage.bareJid.user;
    
    message.from = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPManagerUserName];
    message.fileKey       = nil;
    message.date          = [ICMessageHelper currentMessageTime];
    if ([xmppMessage.body hasPrefix:@"text:"]) {
        message.content = [xmppMessage.body substringFromIndex:5];
        message.type = TypeText;
    } else if ([xmppMessage.body hasPrefix:@"image:"]) {
        message.content = @"[图片]";
        message.type = TypePic;
    } else if ([xmppMessage.body hasPrefix:@"audio:"]) {
        message.content = @"[语音]";
        message.type = TypeVoice;
    } else if ([xmppMessage.body hasPrefix:@"video:"]) {
        message.content = @"[视频]";
        message.type = TypeVideo;
    } else if ([xmppMessage.body hasPrefix:@"file:"]) {
        message.content = xmppMessage.body;
        message.type = TypeFile;
    } else if ([xmppMessage.body hasPrefix:@"syetem:"]) {
        message.content = xmppMessage.body;
        message.type = TypeSystem;
    } else {
        message.type = TypeSystem;
        message.content = xmppMessage.body;
    }
    if ([xmppMessage.outgoing intValue] == 1) { // 发送方
        message.deliveryState = ICMessageDeliveryState_Delivered;
    } else { // 接受方
        message.deliveryState = ICMessageDeliveryState_Delivered;
    }
    
    return message;
}
@end
