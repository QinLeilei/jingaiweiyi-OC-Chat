//
//  TFHttpTools.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/21.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^HttpToolProgressBlock)(CGFloat progress);
typedef void (^HttpToolCompletionBlock)(NSError *error);
@interface TFHttpTools : NSObject
/**
 上传数据
 */
-(void)uploadData:(NSData *)data
              url:(NSURL *)url
   progressBlock : (HttpToolProgressBlock)progressBlock
       completion:(HttpToolCompletionBlock) completionBlock;


/**
 上传数据2

 @param url <#url description#>
 @param parameters <#parameters description#>
 @param fileData <#fileData description#>
 @param name <#name description#>
 @param fileName <#fileName description#>
 @param mimeType <#mimeType description#>
 @param progress <#progress description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
- (void)upLoadToUrlString:(NSString* )url parameters:(NSDictionary* )parameters fileData:(NSData *)fileData name:(NSString* )name fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(void (^)(NSProgress *uploadProgress))progress success:(void (^)(NSURLSessionDataTask* task, id responseObject))success failure:(void (^)(NSURLSessionDataTask* task, NSError* error))failure;
/**
 下载数据
 */
-(void)downLoadFromURL:(NSURL *)url
        progressBlock : (HttpToolProgressBlock)progressBlock
            completion:(HttpToolCompletionBlock) completionBlock;


-(NSString *)fileSavePath:(NSString *)fileName;

@end
