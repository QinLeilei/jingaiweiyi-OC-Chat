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

NSString * const ICMessageTextHasPrefix = @"text:";
NSString * const ICMessageImageHasPrefix = @"image:";
NSString * const ICMessageVoiceHasPrefix = @"voice:";
NSString * const ICMessageVideoHasPrefix = @"video:";
NSString * const ICMessageFilesHasPrefix = @"files:";
NSString * const ICMessageSyetemHasPrefix = @"syetem:";

@implementation ICMessage

+ (ICMessage *)resolveWithXMPPMessageArchiving_Message_CoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)xmppMessage {
    
    ICMessage *message    = [[ICMessage alloc] init];
    
    message.to = xmppMessage.bareJid.user;
    message.from = [xmppMessage.streamBareJidStr substringWithRange:NSMakeRange(0, xmppMessage.streamBareJidStr.length - xmppMessage.bareJid.domain.length - 1)];
    message.fileKey       = nil;
//    message.date          = [ICMessageHelper currentMessageTime];
    
    if ([xmppMessage.body hasPrefix:ICMessageTextHasPrefix]) {
        
        message.content = [xmppMessage.body substringFromIndex:ICMessageTextHasPrefix.length + 33];
        message.localMsgId = [xmppMessage.body substringWithRange:NSMakeRange(ICMessageTextHasPrefix.length, 32)];
        message.type = TypeText;
    } else if ([xmppMessage.body hasPrefix:ICMessageImageHasPrefix]) {
        message.content = [xmppMessage.body substringFromIndex:ICMessageImageHasPrefix.length + 33];
        message.localMsgId = [xmppMessage.body substringWithRange:NSMakeRange(ICMessageImageHasPrefix.length, 32)];
        message.type = TypePic;
    } else if ([xmppMessage.body hasPrefix:ICMessageVoiceHasPrefix]) {
        message.content = [xmppMessage.body substringFromIndex:ICMessageVoiceHasPrefix.length + 33];
        message.localMsgId = [xmppMessage.body substringWithRange:NSMakeRange(ICMessageVoiceHasPrefix.length, 32)];
        message.type = TypeVoice;
    } else if ([xmppMessage.body hasPrefix:ICMessageVideoHasPrefix]) {
        message.content = [xmppMessage.body substringFromIndex:ICMessageVideoHasPrefix.length + 33];
        message.localMsgId = [xmppMessage.body substringWithRange:NSMakeRange(ICMessageVideoHasPrefix.length, 32)];
        message.type = TypeVideo;
    } else if ([xmppMessage.body hasPrefix:ICMessageFilesHasPrefix]) {
        message.content = [xmppMessage.body substringFromIndex:ICMessageFilesHasPrefix.length + 33];
        message.localMsgId = [xmppMessage.body substringWithRange:NSMakeRange(ICMessageFilesHasPrefix.length, 32)];
        message.type = TypeFile;
    } else if ([xmppMessage.body hasPrefix:ICMessageSyetemHasPrefix]) {
        message.content = [xmppMessage.body substringFromIndex:ICMessageSyetemHasPrefix.length + 33];
        message.localMsgId = [xmppMessage.body substringWithRange:NSMakeRange(ICMessageSyetemHasPrefix.length, 32)];
        message.type = TypeSystem;
    } else {
        message.type = TypeSystem;
        message.content = xmppMessage.body;
    }
    
    if ([xmppMessage.outgoing intValue] == 1) { // 发送方
        message.isSender = YES;
        message.deliveryState = ICMessageDeliveryState_Delivered;
    } else { // 接受方
        message.isSender = NO;
        message.deliveryState = ICMessageDeliveryState_Delivered;
    }
    
    return message;
}
@end
