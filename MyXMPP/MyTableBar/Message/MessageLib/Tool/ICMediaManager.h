//
//  ICMediaManager.h
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/3/12.
//  Copyright © 2016年 gxz All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICMessageModel.h"
#import "ICMessageFrame.h"

#define kArrowMe @"Chat/ArrowMe"
#define kMyPic @"Chat/MyPic"
#define kVideoPic @"Chat/VideoPic"
#define kVideoImageType @"png"
#define kDeliver @"Deliver"

@interface ICMediaManager : NSObject

+ (instancetype)sharedManager;

/**
 *  get image from local path
 *
 *  @param localPath 路径
 *
 *  @return 图片
 */
- (UIImage *)imageWithLocalPath:(NSString *)localPath;


- (void)clearReuseImageMessage:(ICMessageModel *)message;

// me to you

/**
 get and save arrow image

 @param image <#image description#>
 @param imageSize <#imageSize description#>
 @param mediaPath <#mediaPath description#>
 @param isSender <#isSender description#>
 @return <#return value description#>
 */
- (UIImage *)arrowMeImage:(UIImage *)image
                     size:(CGSize)imageSize
                mediaPath:(NSString *)mediaPath
                 isSender:(BOOL)isSender;

- (void)saveArrowMeImage:(UIImage *)image
                  withMediaPath:(NSString *)mediPath;

/**
 *  创建图片的保存路径
 *
 *  @param mainFolder  主地址
 *  @param childFolder 子地址
 *
 *  @return 地址
 */
- (NSString *)createFolderPahtWithMainFolder:(NSString *)mainFolder
                                 childFolder:(NSString *)childFolder;

/**
 *  保存图片到沙盒
 *
 *  @param image 图片
 *
 *  @return 图片路径
 */
- (NSString *)saveImage:(UIImage *)image;

- (void)clearCaches;

// 发送图片的地址
- (NSString *)sendImagePath:(NSString *)imgName;

/// video first cover image
- (UIImage *)videoConverPhotoWithVideoPath:(NSString *)videoPath
                                      size:(CGSize)imageSize
                                  isSender:(BOOL)isSender;


// 保存接收到图片 small-fileKey.png
- (NSString *)receiveImagePathWithFileKey:(NSString *)fileKey
                                     type:(NSString *)type;

// 小图路径

/**
 缩略图路径

 @param fileKey <#fileKey description#>
 @return <#return value description#>
 */
- (NSString *)smallImgPath:(NSString *)fileKey;


/**
 原图路径

 @param messageF <#messageF description#>
 @return <#return value description#>
 */
- (NSString *)originImgPath:(ICMessageFrame *)messageF;


/**
 根据图片名字获取本地路径

 @param imageName <#imageName description#>
 @return <#return value description#>
 */
- (NSString *)imagePathWithName:(NSString *)imageName;

// get videoImage from sandbox
- (UIImage *)videoImageWithFileName:(NSString *)fileName;

// 送达号
- (NSString *)delieveImagePath:(NSString *)fileKey;
- (NSString *)deliverFilePath:(NSString *)name
                         type:(NSString *)type;

- (NSString *)videoImagePath:(NSString *)fileName;

@end
