//
//  Config.h
//  YunShangShiJi
//
//  Created by jingaiweiyi on 16/7/5.
//  Copyright © 2016年 ios-1. All rights reserved.
//

#ifndef Config_h
#define Config_h
/**
 *  颜色设置
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBCOLOR_I(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR_I(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
/**< 玫红色 */
#define TF_ROSERED_COLOR [UIColor colorWithRed:255/255.f green:63/255.f blue:139/255.f alpha:1]
/**< 随机色 */
#define TF_RANDOM_COLOR [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]


/**
 *  手机型号
 */
#define kDevice_Is_iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/**
 *  屏幕
 */

//导航栏，屏幕宽高，版本，语言
#define kScreen_Bounds [UIScreen mainScreen].bounds
#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width

#define kNavigationBar_Height 44.0f
#define kTabBar_Height 49.0f
#define kStatusBar_Height 20.0f
#define kToolsBar_Height 44.0f
#define kStatusBar_And_NavigationBar_Height (kStatusBar_Height+kNavigationBar_Height)
#define kMainContent_Height (kScreen_Height-kStatusBar_And_NavigationBar_Height)

#define kIOS_Version [[[UIDevice currentDevice] systemVersion] floatValue]
#define kCurrentSystemVersion ([[UIDevice currentDevice] systemVersion])
#define kCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

/**
 *  文件
 */
//获取 temp
#define kPathTemp NSTemporaryDirectory()
//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

/**
 *  字体
 */
#define kSysFont(pt) [UIFont systemFontOfSize:(pt)]

#define kNavTitleFontSize 18
#define kNavTitleButtonFontSize 16


/**
 *  GCD 的宏定义
 */
//GCD - 一次性执行
#define kDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);
//GCD - 在Main线程上运行
#define kDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);
//GCD - 开启异步线程
#define kDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);

#define LogFunc MyLog(@"%s", __func__)
#define kUnNilAndNULL(obj) (((obj) !=nil ) && ![(obj) isEqual:[NSNull null]])

//读取本地图片
#define kLoad_ImageFile(file, type) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:type]]

//弱引用/强引用
#define kWeakSelf(type)  __weak typeof(type) weak##type = type;
#define kStrongSelf(type)  __strong typeof(type) type = weak##type;


#endif /* Config_h */
