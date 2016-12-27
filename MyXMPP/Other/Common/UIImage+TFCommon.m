//
//  UIImage+TFCommon.m
//  YunShangShiJi
//
//  Created by jingaiweiyi on 16/7/12.
//  Copyright © 2016年 ios-1. All rights reserved.
//

#import "UIImage+TFCommon.h"

@implementation UIImage (TFCommon)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

// 宽确定，等比例求高
+ (CGFloat)imageConvertHeightWithImage:(UIImage *)sourceImage fromWidth:(CGFloat)width
{
    CGFloat convertHeight = 0;
    if (sourceImage == nil || width == 0) {
        return convertHeight;
    }
    CGSize imageSize = sourceImage.size;
    convertHeight = imageSize.height*width/imageSize.width;
    
    return convertHeight;
}
// 高确定，等比例求宽
+ (CGFloat)imageConvertWidthWithImage:(UIImage *)sourceImage fromHeight:(CGFloat)height
{
    CGFloat convertWidth = 0;
    if (sourceImage == nil || height == 0) {
        return convertWidth;
    }
    CGSize imageSize = sourceImage.size;
    convertWidth = imageSize.width*height/imageSize.height;
    return convertWidth;
}


//  把一张图压缩成指定尺寸
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    // 如果在视网膜下修改图片大小，会使画质变差, 解决方法
    //Determine whether the screen is retina
    
    if([[UIScreen mainScreen] scale] == 2.0){ // @2x
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    } else if([[UIScreen mainScreen] scale] == 3.0){ // @3x ( iPhone 6plus 、iPhone6s plus)
        UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    } else{
        UIGraphicsBeginImageContext(size);
    }
    
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
    
}

//  把一张图等比例压缩成指定尺寸 (图片显示不完整)
+ (UIImage *) imageCompressForSizeSourceImage:(UIImage *)sourceImage targetSize:(CGSize)size
{
    UIImage *newImage = nil;
    CGSize  sourceImageSize = sourceImage.size;
    CGFloat sourceImageWidth = sourceImageSize.width;
    CGFloat sourceImageHeight = sourceImageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(sourceImageSize, size) == NO){
        CGFloat widthFactor = targetWidth / sourceImageWidth; // 宽系数
        CGFloat heightFactor = targetHeight / sourceImageHeight; // 高系数

        if(widthFactor > heightFactor){ // 采用系数大的(那么那个targetSize就不用变)
            scaleFactor = widthFactor;
        } else{
            scaleFactor = heightFactor;
        }
        
        scaledWidth = sourceImageWidth * scaleFactor;
        scaledHeight = sourceImageHeight * scaleFactor;
        
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5; // 为了不变形，需要截取
        }
    }
    
    //UIGraphicsBeginImageContext(size); // size 上下文（画布）的大小
    //  让图片不模糊, 生成对应的倍图
    if([[UIScreen mainScreen] scale] == 2.0){ // @2x
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    } else if([[UIScreen mainScreen] scale] == 3.0){ // @3x ( iPhone 6plus 、iPhone6s plus)
        UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    } else{
        UIGraphicsBeginImageContext(size);
    }
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint; // x = -30, 画框向右移30
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //MyLog(@"thumbnailRect: %@", NSStringFromCGRect(thumbnailRect));
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
    
}

//  把一张图按等比例压缩成指定宽（宽已经限定）(图片可显示完整)
+(UIImage *) imageCompressForWidthSourceImage:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    UIImage *newImage = nil;
    CGSize sourceImageSize = sourceImage.size;
    CGFloat sourceImageWidth = sourceImageSize.width;
    CGFloat sourceImageHeight = sourceImageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = sourceImageHeight / (sourceImageWidth / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(sourceImageSize, size) == NO){
        CGFloat widthFactor = targetWidth / sourceImageWidth;
        CGFloat heightFactor = targetHeight / sourceImageHeight;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        } else{
            scaleFactor = heightFactor;
        }
        scaledWidth = sourceImageWidth * scaleFactor;
        scaledHeight = sourceImageHeight * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    //UIGraphicsBeginImageContext(size);
    //  让图片不模糊
    if([[UIScreen mainScreen] scale] == 2.0){ // @2x
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    } else if([[UIScreen mainScreen] scale] == 3.0){ // @3x ( iPhone 6plus 、iPhone6s plus)
        UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    } else{
        UIGraphicsBeginImageContext(size);
    }
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}
//压缩图片质量  
+(UIImage *)reduceSourceImage:(UIImage *)sourceImage percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(sourceImage, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}

// 压缩图片至指定文件大小
// maxFileSize: 100*1024 = 100KB
+(UIImage *)compressSourceImage:(UIImage *)sourceImage toMaxFileSize:(NSInteger)maxFileSize
{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(sourceImage, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(sourceImage, compression);
        
    }
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}
+ (UIImage *)imageDefaultWithSize:(CGSize)size compress:(float)compress
{
    UIImage *image = [UIImage imageNamed:@"默认图片"];
    CGRect frame = CGRectZero;
    CGFloat width = size.width*compress;
    image = [UIImage imageCompressForWidthSourceImage:image targetWidth:width];
    CGFloat height = image.size.height;
    
    if([[UIScreen mainScreen] scale] == 2.0){ // @2x
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    } else if([[UIScreen mainScreen] scale] == 3.0){ // @3x ( iPhone 6plus 、iPhone6s plus)
        UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    } else{
        UIGraphicsBeginImageContext(size);
    }
    
    frame.origin.x = (size.width-width)*0.5;
    frame.origin.y = (size.height-height)*0.5;
    frame.size.width = width;
    frame.size.height = height;
    
    [image drawInRect:frame];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageDefaultWithSize:(CGSize)size
{
    return [self imageDefaultWithSize:size compress:0.618];
}

@end
