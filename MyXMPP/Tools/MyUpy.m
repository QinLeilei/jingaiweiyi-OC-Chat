//
//  MyUpy.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/22.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "MyUpy.h"
#import "AFNetworking.h"
#import "TFHttpTools.h"
#import "MF_Base64Additions.h"
#import "NSData+MD5Digest.h"
#import "NSData+Utils.h"
#define DATE_STRING(expiresIn) [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + expiresIn]

NSString const *kGetUpy = @"https://yssj-real-test.b0.upaiyun.com/";
NSString const *kBaseUpy = @"https://v0.api.upyun.com/yssj-real-test/";
static NSString * const bucket = @"yssj-real-test";
static NSString * const passcode = @"T8CDRaESN017je6QcRjYqmjxXkw=";
static NSTimeInterval const expiresIn = 600;

@interface MyUpy ()

@property (nonatomic, copy) NSMutableDictionary *params;

@end

@implementation MyUpy

- (void)setProgress:(void(^)(NSProgress *uploadProgress))progress success:(void (^)(NSURLSessionDataTask* task, id responseObject)) success failure:(void (^)(NSURLSessionDataTask* task, NSError* error))failure  {
    self.progressBlock = progress;
    self.failureBlock = failure;
    self.successBlock = success;
}

- (void) uploadImage:(UIImage *)image savekey:(NSString *)savekey
{
    NSData *imageData = UIImagePNGRepresentation(image);
    [self uploadImageData:imageData savekey:savekey];
}

- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey
{
    [self uploadFileData:data savekey:savekey];
}

- (void) uploadFileData:(NSData *)data savekey:(NSString *)savekey
{
    NSLog(@"savekey: %@", savekey);
    
    NSString *policy = [self getPolicyWithSaveKey:savekey];
    NSString *signature = [self getSignatureWithPolicy:policy];
    NSDictionary * parameters = @{@"policy":policy, @"signature":signature};
    TFHttpTools *httpTools = [[TFHttpTools alloc] init];
    NSString *string = [NSString stringWithFormat:@"%@", kBaseUpy];
    
    [httpTools upLoadToUrlString:string parameters:parameters fileData:data name:@"file" fileName:[NSString stringWithFormat:@"file%@", [data detectImageSuffix]] mimeType:@"multipart/form-data" progress:^(NSProgress *uploadProgress) {
        if (self.progressBlock) {
            self.progressBlock(uploadProgress);
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"成功: responseObject: %@", responseObject);
        if (self.successBlock) {
            self.successBlock(task, responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"失败: error: %@", error);
        if (self.failureBlock) {
            self.failureBlock(task, error);
        }
    }];
}

- (NSString *)getSignatureWithPolicy:(NSString *)policy
{
    NSString *str = [NSString stringWithFormat:@"%@&%@",policy,passcode];
    NSString *signature = [[[str dataUsingEncoding:NSUTF8StringEncoding] MD5HexDigest] lowercaseString];
    return signature;
}

- (NSString *)getPolicyWithSaveKey:(NSString *)savekey {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:bucket forKey:@"bucket"];
    [dic setObject:DATE_STRING(expiresIn) forKey:@"expiration"];
    if (savekey && ![savekey isEqualToString:@""]) {
        [dic setObject:savekey forKey:@"save-key"];
    }
    
    if (self.params) {
        for (NSString *key in self.params.keyEnumerator) {
            [dic setObject:[self.params objectForKey:key] forKey:key];
        }
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:NULL];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [json base64String];
}


@end
