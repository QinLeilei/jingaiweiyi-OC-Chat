//
//  NSDate+TFCommon.m
//  YunShangShiJi
//
//  Created by jingaiweiyi on 16/8/25.
//  Copyright © 2016年 ios-1. All rights reserved.
//

#import "NSDate+TFCommon.h"

NSString *const TFDateFormatyyyyMMddHHmmss = @"yyyyMMddHHmmss";//年月日时分秒
NSString *const TFDateFormatMMddHHmmss = @"MMddHHmmss";//月日时分秒
NSString *const TFDateFormatHHmmss = @"HHmmss";//时分秒

@implementation NSDate (TFCommon)

+(NSString *)nowDateFormat:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:[NSDate date]];
}

//@"yyyy/MM/dd hh:mm:ss"
+ (NSString *)stringCurrDateWithFormatterString:(NSString *)formatterString
{
    NSDate *date = [self date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatterString];
    return [dateFormatter stringFromDate:date];
}

+ (MyDateFormatterStruct)dateComponentsWithDate:(NSDate *)theDate
{
    NSDateComponents *com = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:theDate];
    NSInteger year        = com.year;
    NSInteger month       = com.month;
    NSInteger day         = com.day;
    NSInteger hour        = com.hour;
    NSInteger minute      = com.minute;
    NSInteger second      = com.second;
    
    MyDateFormatterStruct dateDtruct = {};
    dateDtruct.year = year;
    dateDtruct.month = month;
    dateDtruct.day = day;
    dateDtruct.hour = hour;
    dateDtruct.minute = minute;
    dateDtruct.second = second;
    
    return dateDtruct;
}

+ (MyDateFormatterStruct)dateComponentsWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSDate *currSystemDate = [NSDate date];         // 获得时间对象
    NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区
    NSTimeInterval diffTimeInter = [zone secondsFromGMTForDate:currSystemDate];
    // 以秒为单位返回当前时间与系统格林尼治时间的差
    //NSDate *nowDate = [currSystemDate dateByAddingTimeInterval:diffTimeInter];   // 然后把差的时间加上,就是当前系统准确的时间
    
    NSTimeInterval cacalTimeInter = timeInterval-diffTimeInter*1000;
    
    NSDate *date = [self dateWithtimeIntervalSince1970ms:cacalTimeInter];
    
    MyDateFormatterStruct dateDtruct = [self dateComponentsWithDate:date];
    dateDtruct.year = dateDtruct.year-1970;
    dateDtruct.month = dateDtruct.month-1;
    dateDtruct.day = dateDtruct.day-1;
    return dateDtruct;
}

+ (NSTimeInterval)timeIntervalSince1970WithDate
{
    NSDate *currDate = [self date];
    NSTimeInterval timeInter = [currDate timeIntervalSince1970];
    return (timeInter)*1000;
}

+ (NSDate *)dateWithtimeIntervalSince1970ms:(NSTimeInterval)timeInterval
{
    NSDate *sameDate = [self dateWithTimeIntervalSince1970:(timeInterval/1000)];
    return sameDate;
}

@end
