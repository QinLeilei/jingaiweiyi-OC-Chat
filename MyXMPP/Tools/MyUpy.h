//
//  MyUpy.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/22.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *kBaseUpy;
extern NSString const *kGetUpy;
@interface MyUpy : NSObject

@property (nonatomic, copy) void(^progressBlock)(NSProgress *uploadProgress);

@property (nonatomic, copy) void (^successBlock)(NSURLSessionDataTask* task, id responseObject);

@property (nonatomic, copy) void (^failureBlock)(NSURLSessionDataTask* task, NSError* error);

- (void)setProgress:(void(^)(NSProgress *uploadProgress))progress success:(void (^)(NSURLSessionDataTask* task, id responseObject)) success failure:(void (^)(NSURLSessionDataTask* task, NSError* error))failure ;

// 上传图片
- (void)uploadImage:(UIImage *)image savekey:(NSString *)savekey;
// 上传文件
- (void)uploadVoiceData:(NSData *)data savekey:(NSString *)savekey;
@end
