//
//  UIButton+TFCommon.h
//  YunShangShiJi
//
//  Created by jingaiweiyi on 2016/11/28.
//  Copyright © 2016年 ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ButtonClickBlock)(UIButton *sender);
@interface UIButton (TFCommon)
-(void)handleClickEvent:(UIControlEvents)aEvent withClickBlock:(ButtonClickBlock)block;
@end
