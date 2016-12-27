//
//  UIImage+TFCommon.h
//  YunShangShiJi
//
//  Created by jingaiweiyi on 16/7/12.
//  Copyright © 2016年 ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TFCommon)

+ (UIImage *)imageWithColor:(UIColor *)color;

// 宽确定，等比例求高
+ (CGFloat)imageConvertHeightWithImage:(UIImage *)sourceImage fromWidth:(CGFloat)width;
// 高确定，等比例求宽
+ (CGFloat)imageConvertWidthWithImage:(UIImage *)sourceImage fromHeight:(CGFloat)height;
//图片的压缩其实是俩概念，
//  1、是 “压” 文件体积变小，但是像素数不变，长宽尺寸不变，那么质量可能下降，
//  2、是 “缩” 文件的尺寸变小，也就是像素数减少。长宽尺寸变小，文件体积同样会减小。
//  得结合使用来满足需求，不然你一味的用1，导致，图片模糊的不行，但是尺寸还是很大。

//  把一张图压缩成指定尺寸
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
//  把一张图等比例压缩成指定尺寸(取中间部分)
+ (UIImage *) imageCompressForSizeSourceImage:(UIImage *)sourceImage targetSize:(CGSize)size
;
//  把一张图按等比例压缩成指定宽（宽已经限定）
+(UIImage *) imageCompressForWidthSourceImage:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
//  压缩图片质量
+(UIImage *)reduceSourceImage:(UIImage *)sourceImage percent:(float)percent;

// 压缩图片至指定文件大小
+(UIImage *)compressSourceImage:(UIImage *)sourceImage toMaxFileSize:(NSInteger)maxFileSize;

+ (UIImage *)imageDefaultWithSize:(CGSize)size compress:(float)compress;
+ (UIImage *)imageDefaultWithSize:(CGSize)size;

@end
