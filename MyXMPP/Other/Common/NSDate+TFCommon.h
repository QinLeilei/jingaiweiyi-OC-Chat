//
//  NSDate+TFCommon.h
//  YunShangShiJi
//
//  Created by jingaiweiyi on 16/8/25.
//  Copyright © 2016年 ios-1. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern常用于定义常量 其常量本身的内容在其它位置定义
extern NSString *const TFDateFormatyyyyMMddHHmmss;//年月日时分秒
extern NSString *const TFDateFormatMMddHHmmss;//月日时分秒
extern NSString *const TFDateFormatHHmmss;//时分秒

typedef struct DateFormatterStruct {
    NSInteger year;
    NSInteger month;
    NSInteger day;
    NSInteger hour;
    NSInteger minute;
    NSInteger second;
} MyDateFormatterStruct;

@interface NSDate (TFCommon)

/**
 *  返回格式化后的字符串 如果201401011212（年月时分秒）
 */
+(NSString *)nowDateFormat:(NSString *)format;

//将当前对时间显示出来
// @"yyyy/MM/dd hh:mm:ss"

// NSDate -> NSString
+ (NSString *)stringCurrDateWithFormatterString:(NSString *)formatterString;

// NSDate -> 具体时间
+ (MyDateFormatterStruct)dateComponentsWithDate:(NSDate *)theDate;

// 现在的时间戳
+ (NSTimeInterval)timeIntervalSince1970WithDate;

// 从后台拿时间，转成date
// NSTimeInterval -> NSDate
// 时间戳ms 转成 NSDate
+ (NSDate *)dateWithtimeIntervalSince1970ms:(NSTimeInterval)timeInterval;

// 一段时间戳(ms) 转成具体时间
+ (MyDateFormatterStruct)dateComponentsWithTimeInterval:(NSTimeInterval)timeInterval;

@end
