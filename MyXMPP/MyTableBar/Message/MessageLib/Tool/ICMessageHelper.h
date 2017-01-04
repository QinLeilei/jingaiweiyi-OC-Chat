//
//  ICMessageHelper.h
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/4/7.
//  Copyright © 2016年 gxz All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICMessageFrame;
@class ICMessage;
@class ICMessageModel;

typedef void(^Finish)(ICMessageFrame *messageF);
//typedef void(^FinishText)(NSDictionary *data);

@interface ICMessageHelper : NSObject


#pragma mark - 唐飞

/**
 创建一条消息

 @param message <#message description#>
 @return <#return value description#>
 */
+ (ICMessageFrame *)createMessageFrameWithMessage:(ICMessage *)message;

/**
 创建一条本地文本消息

 @param content <#content description#>
 @param from <#from description#>
 @param to <#to description#>
 @return <#return value description#>
 */
+ (ICMessageFrame *)createLocalTextMessageFrameWithContent:(NSString *)content
                                                      from:(NSString *)from
                                                        to:(NSString *)to;

/**
 创建一条本地图片消息

 @param content <#content description#>
 @param from <#from description#>
 @param to <#to description#>
 @return <#return value description#>
 */
+ (ICMessageFrame *)createLocalImageMessageFrameWithContent:(NSString *)content
                                                       from:(NSString *)from
                                                         to:(NSString *)to localMediaPath:(NSString *)localMediaPath;

/**
 创建一条本地语音消息

 @param content <#content description#>
 @param from <#from description#>
 @param to <#to description#>
 @param localMediaPath <#localMediaPath description#>
 @return <#return value description#>
 */
+ (ICMessageFrame *)createLocalVoiceMessageFrameWithContent:(NSString *)content
                                                       from:(NSString *)from
                                                         to:(NSString *)to localMediaPath:(NSString *)localMediaPath;


+ (CGFloat)getVoiceTimeLengthWithPath:(NSString *)path;


// 坐标转换到窗口中的位置
+ (CGRect)photoFramInWindow:(UIButton *)photoView;

// 放大后的图片按钮在窗口中的位置
+ (CGRect)photoLargerInWindow:(UIButton *)photoView;


//+ (NSString *)senderNameWithID:(NSString *)ID;

// 根据消息类型得到cell的标识
+ (NSString *)cellTypeWithMessageType:(NSString *)type;

// 删除消息附件
+ (void)deleteMessage:(ICMessageModel *)messageModel;


// time format
+ (NSString *)timeFormatWithDate:(NSInteger)time;



+ (NSString *)timeFormatWithDate2:(NSInteger)time;


+ (NSNumber *)fileType:(NSString *)type;
+ (UIImage *)allocationImage:(ICFileType)type;

+ (NSString *)timeDurationFormatter:(NSUInteger)duration;

/// 当前时间
+ (NSInteger)currentMessageTime;

/**
 获取本地消息Id

 @param message <#message description#>
 @return <#return value description#>
 */
+ (NSString *)localMsgId:(NSString *)message;
@end
