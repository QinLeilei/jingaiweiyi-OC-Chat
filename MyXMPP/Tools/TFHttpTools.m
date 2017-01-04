//
//  TFHttpTools.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/21.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "TFHttpTools.h"
#define kTimeOut 5.0

@interface TFHttpTools () <NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate>{
    
    //下载
    HttpToolProgressBlock _dowloadProgressBlock;
    HttpToolCompletionBlock _downladCompletionBlock;
    NSURL *_downloadURL;
    
    //上传
    HttpToolProgressBlock _uploadProgressBlock;
    HttpToolCompletionBlock _uploadCompletionBlock;
}


@end

@implementation TFHttpTools

#pragma mark - 上传
-(void)uploadData:(NSData *)data url:(NSURL *)url progressBlock:(HttpToolProgressBlock)progressBlock completion:(HttpToolCompletionBlock)completionBlock{
    
    NSAssert(data != nil, @"上传数据不能为空");
    NSAssert(url != nil, @"上传文件路径不能为空");
    
    _uploadProgressBlock = progressBlock;
    _uploadCompletionBlock = completionBlock;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeOut];
//    request.HTTPMethod = @"PUT";
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //NSURLSessionDownloadDelegate
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    
    //定义下载操作
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data];
    
    [uploadTask resume];
}

#pragma mark - 上传代理


#pragma mark - 上传进度
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    if (_uploadProgressBlock) {
        CGFloat progress = (CGFloat) totalBytesSent / totalBytesExpectedToSend;
        _uploadProgressBlock(progress);
    }
}


#pragma mark - 上传完成
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (_uploadCompletionBlock) {
        _uploadCompletionBlock(error);
        
        _uploadProgressBlock = nil;
        _uploadCompletionBlock = nil;
    }
}


#pragma mark - 下载
-(void)downLoadFromURL:(NSURL *)url
         progressBlock:(HttpToolProgressBlock)progressBlock
            completion:(HttpToolCompletionBlock)completionBlock{
    NSAssert(url != nil, @"下载URL不能传空");
    
    _downloadURL = url;
    _dowloadProgressBlock = progressBlock;
    _downladCompletionBlock = completionBlock;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeOut];
    
    
    //session 大多数使用单例即可
    
    NSURLResponse *response = nil;
    
    
    //发达同步请求
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    //NSLog(@"%lld",response.expectedContentLength);
    if (response.expectedContentLength <= 0) {
        if (_downladCompletionBlock) {
            NSError *error =[NSError errorWithDomain:@"文件不存在" code:404 userInfo:nil];
            _downladCompletionBlock(error);
            
            //清除block
            _downladCompletionBlock = nil;
            _dowloadProgressBlock = nil;
        }
        
        return;
    }
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    
    //NSURLSessionDownloadDelegate
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    
    //定义下载操作
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    
    [downloadTask resume];
    
}


#pragma mark -NSURLSessionDownloadDelegate
#pragma mark 下载完成
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    //图片保存在沙盒的Doucument下
    NSString *fileSavePath = [self fileSavePath:[_downloadURL lastPathComponent]];
    
    //文件管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtURL:location toURL:[NSURL fileURLWithPath:fileSavePath] error:nil];
    
    if (_downladCompletionBlock) {
        //通知下载成功，没有没有错误
        _downladCompletionBlock(nil);
        
        //清空block
        _downladCompletionBlock = nil;
        _dowloadProgressBlock = nil;
    }
    
}

#pragma mark 下载进度
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    
    if (_dowloadProgressBlock) {
        //已写数据字节数除以总字节数就是下载进度
        CGFloat progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;
        
        _dowloadProgressBlock(progress);
        
    }
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}


#pragma mark - 传一个文件名，返回一个在沙盒Document下的文件路径
-(NSString *)fileSavePath:(NSString *)fileName{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    //图片保存在沙盒的Doucument下
    return [document stringByAppendingPathComponent:fileName];
}


/**
 <#Description#>
 
 @param url 服务器地址
 @param parameters 字典 token
 @param fileData 要上传的数据
 @param name 服务器参数名称 后台给你
 @param fileName 文件名称 图片:xxx.jpg,xxx.png 视频:video.mov
 @param mimeType 文件类型 图片:image/jpg,image/png 视频:video/quicktime
 @param progress 进度
 @param success 成功回调
 @param failure 失败回调
 */
- (void)upLoadToUrlString:(NSString* )url parameters:(NSDictionary* )parameters fileData:(NSData *)fileData name:(NSString* )name fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(void (^)(NSProgress *uploadProgress))progress success:(void (^)(NSURLSessionDataTask* task, id responseObject))success failure:(void (^)(NSURLSessionDataTask* task, NSError* error))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
//                                                         @"text/html",
//                                                         @"image/jpeg",
//                                                         @"image/png",
//                                                         @"application/octet-stream",
//                                                         @"text/json",
//                                                         nil];
    
    NSURLSessionDataTask *task = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // formData 将要上传的数据
        // 方法一
        /**
         data:上传文件二进制数据
         name:接口的名字
         fileName:文件上传到服务器之后叫什么名字
         mineType:上传文件的类型，可以上传任意二进制mineType.
         */
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
        // 方法二
        /**
         data:上传文件二进制数据
         name:接口的名字
         这种方法内部会将文件名当做上传到服务器之后的名字，并自动获取其类型
         */
        //        [formData appendPartWithFormData:fileData name:@"file"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //打印下上传进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //上传成功
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //上传失败
        if (failure) {
            failure(task, error);
        }
    }];
}

//AFNetworking 2.X
//- (void)downloadFileWithOption:(NSDictionary *)parameters
//                 withInferface:(NSString*)requestURL
//                     savedPath:(NSString*)savedPath
//               downloadSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//               downloadFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//                      progress:(void (^)(float progress))progress
//
//{
//    
//    //沙盒路径    //NSString *savedPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/xxx.zip"];
//    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
//    NSMutableURLRequest *request =[serializer requestWithMethod:@"POST" URLString:requestURL parameters:parameters error:nil];
//    
//    //以下是手动创建request方法 AFQueryStringFromParametersWithEncoding有时候会保存
//    //    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
//    //   NSMutableURLRequest *request =[[[AFHTTPRequestOperationManager manager]requestSerializer]requestWithMethod:@"POST" URLString:requestURL parameters:paramaterDic error:nil];
//    //
//    //    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
//    //
//    //    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
//    //    [request setHTTPMethod:@"POST"];
//    //
//    //    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(paramaterDic, NSASCIIStringEncoding) dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
//    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath append:NO]];
//    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        float p = (float)totalBytesRead / totalBytesExpectedToRead;
//        progress(p);
//        NSLog(@"download：%f", (float)totalBytesRead / totalBytesExpectedToRead);
//        
//    }];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        success(operation,responseObject);
//        NSLog(@"下载成功");
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        success(operation,error);
//        
//        NSLog(@"下载失败");
//        
//    }];
//    
//    [operation start];
//    
//}

//AFNetworking 3.X
- (void)downloadFileWithURL:(NSString*)requestURLString
                 parameters:(NSDictionary *)parameters
                  savedPath:(NSString*)savedPath
            downloadSuccess:(void (^)(NSURLResponse *response, NSURL *filePath))success
            downloadFailure:(void (^)(NSError *error))failure
           downloadProgress:(void (^)(NSProgress *downloadProgress))progress

{
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request =[serializer requestWithMethod:@"GET" URLString:requestURLString parameters:parameters error:nil];
    NSURLSessionDownloadTask *task = [[AFHTTPSessionManager manager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:savedPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(error){
            if (failure) {
                failure(error);
            }
        } else{
            if (success) {
                success(response,filePath);
            }
        }
    }];
    [task resume];
    
}

@end
